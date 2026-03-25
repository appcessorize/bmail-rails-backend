require "cbor"
require "openssl"
require "digest"
require "base64"

class AppAttestVerificationService
  class VerificationError < StandardError; end

  APPLE_APP_ATTEST_ROOT_CA_PATH = Rails.root.join("config", "certs", "Apple_App_Attestation_Root_CA.pem")
  APPLE_ROOT_CA_G3_PATH = Rails.root.join("config", "certs", "Apple_Root_CA_G3.pem")
  PRODUCTION_AAGUID = "appattestdevelop".bytes.pack("C*") # 16 bytes, will check both
  DEVELOPMENT_AAGUID = "appattestdevelop".bytes.pack("C*")

  TEAM_ID = ENV.fetch("APPLE_TEAM_ID", "")
  BUNDLE_ID = ENV.fetch("APPLE_BUNDLE_ID", "")

  def verify_attestation(attestation_object_b64, key_id, challenge, user)
    attestation_data = Base64.decode64(attestation_object_b64)
    attestation = CBOR.decode(attestation_data)

    fmt = attestation["fmt"]
    raise VerificationError, "unsupported format: #{fmt}" unless fmt == "apple-appattest"

    att_stmt = attestation["attStmt"]
    auth_data_bytes = attestation["authData"]

    x5c = att_stmt["x5c"]
    raise VerificationError, "missing x5c certificate chain" if x5c.nil? || x5c.empty?

    # Parse certificates
    leaf_cert = OpenSSL::X509::Certificate.new(x5c[0])
    intermediate_certs = x5c[1..].map { |c| OpenSSL::X509::Certificate.new(c) }

    # Verify certificate chain against Apple Root CA
    verify_certificate_chain(leaf_cert, intermediate_certs)

    # Verify nonce
    # nonce = SHA256(SHA256(challenge) || authData)
    client_data_hash = Digest::SHA256.digest(challenge)
    composite = auth_data_bytes + client_data_hash
    expected_nonce = Digest::SHA256.digest(composite)

    # The nonce is in the leaf certificate's OID 1.2.840.113635.100.8.2
    cert_nonce = extract_nonce_from_cert(leaf_cert)
    raise VerificationError, "nonce mismatch" unless cert_nonce == expected_nonce

    # Extract public key from leaf certificate
    public_key = leaf_cert.public_key
    raise VerificationError, "not an EC key" unless public_key.is_a?(OpenSSL::PKey::EC)

    # Parse authenticator data
    parsed_auth_data = parse_authenticator_data(auth_data_bytes)

    # Verify RP ID (app ID = team_id.bundle_id)
    expected_rp_id_hash = Digest::SHA256.digest("#{TEAM_ID}.#{BUNDLE_ID}")
    raise VerificationError, "rp_id mismatch" unless parsed_auth_data[:rp_id_hash] == expected_rp_id_hash

    # Verify key_id matches credentialId in authData
    credential_id_b64 = Base64.encode64(parsed_auth_data[:credential_id]).strip
    raise VerificationError, "key_id mismatch" unless key_id == credential_id_b64 || key_id == parsed_auth_data[:credential_id].unpack1("H*")

    # Determine environment from aaguid
    aaguid = parsed_auth_data[:aaguid]
    environment = if aaguid == "appattestdevelop"
      "development"
    else
      "production"
    end

    # Store credential
    pub_key_der = public_key.to_der
    Rails.logger.info("[AppAttest] Storing public_key DER size: #{pub_key_der.bytesize}, hex: #{pub_key_der.unpack1('H*')}")

    credential = user.app_attest_credentials.create!(
      key_id: key_id,
      public_key: pub_key_der,
      receipt: att_stmt["receipt"],
      sign_count: parsed_auth_data[:sign_count],
      environment: environment
    )

    # Self-test: verify we can read back the key and use it
    stored_der = credential.reload.public_key
    Rails.logger.info("[AppAttest] Read-back DER size: #{stored_der.bytesize}, hex: #{stored_der.unpack1('H*')}")
    Rails.logger.info("[AppAttest] DER match: #{pub_key_der == stored_der}")

    begin
      read_back_key = OpenSSL::PKey.read(stored_der)
      test_data = "test"
      test_sig = public_key.sign("SHA256", test_data)
      test_verify = read_back_key.verify("SHA256", test_sig, test_data)
      Rails.logger.info("[AppAttest] Self-test sign+verify: #{test_verify}")
    rescue => e
      Rails.logger.error("[AppAttest] Self-test failed: #{e.class} #{e.message}")
    end

    credential
  end

  def verify_assertion(assertion_data, credential, client_data_hash)
    assertion = CBOR.decode(assertion_data)

    Rails.logger.info("[AppAttest] Assertion CBOR keys: #{assertion.keys.inspect}")
    authenticator_data = assertion["authenticatorData"] || assertion.values.first
    signature = assertion["signature"] || assertion.values.last

    raise VerificationError, "missing authenticator data" unless authenticator_data
    raise VerificationError, "missing signature" unless signature

    Rails.logger.info("[AppAttest] authenticator_data size: #{authenticator_data.bytesize}, signature size: #{signature.bytesize}")
    Rails.logger.info("[AppAttest] client_data_hash: #{client_data_hash.unpack1('H*')}")

    # Compute message = authenticatorData + clientDataHash
    message = authenticator_data + client_data_hash
    Rails.logger.info("[AppAttest] message size: #{message.bytesize}")

    # Verify signature with stored public key
    begin
      public_key = OpenSSL::PKey.read(credential.public_key)
    rescue => e
      Rails.logger.info("[AppAttest] PKey.read failed (#{e.message}), falling back to EC.new")
      public_key = OpenSSL::PKey::EC.new(credential.public_key)
    end
    Rails.logger.info("[AppAttest] public_key class: #{public_key.class}, curve: #{public_key.group.curve_name rescue 'unknown'}")
    Rails.logger.info("[AppAttest] stored public_key DER size: #{credential.public_key.bytesize}")
    Rails.logger.info("[AppAttest] stored public_key hex (first 40): #{credential.public_key.unpack1('H*')[0..79]}")

    # Method 1: Standard verify
    verified = public_key.verify("SHA256", signature, message) rescue false
    Rails.logger.info("[AppAttest] verify(SHA256) result: #{verified}")

    unless verified
      # Method 2: dsa_verify_asn1 with pre-computed hash
      message_hash = Digest::SHA256.digest(message)
      verified_dsa = (public_key.dsa_verify_asn1(message_hash, signature) rescue false)
      Rails.logger.info("[AppAttest] dsa_verify_asn1 result: #{verified_dsa}")

      unless verified_dsa
        # Method 3: Try with Digest object instead of string
        verified_digest_obj = (public_key.verify(OpenSSL::Digest.new("SHA256"), signature, message) rescue false)
        Rails.logger.info("[AppAttest] verify(Digest.new) result: #{verified_digest_obj}")

        # Method 4: Reconstruct key from raw point and try
        begin
          raw_point = credential.public_key
          key2 = OpenSSL::PKey::EC.new("prime256v1")
          key2.public_key = OpenSSL::PKey::EC::Point.new(
            OpenSSL::PKey::EC::Group.new("prime256v1"),
            OpenSSL::BN.new(raw_point[-65..-1].unpack1("H*"), 16)
          )
          verified_reconstructed = key2.verify("SHA256", signature, message) rescue false
          Rails.logger.info("[AppAttest] verify(reconstructed key) result: #{verified_reconstructed}")
        rescue => e
          Rails.logger.info("[AppAttest] key reconstruction failed: #{e.message}")
        end

        # Log hex of signature and authenticator_data for manual verification
        Rails.logger.info("[AppAttest] signature hex: #{signature.unpack1('H*')}")
        Rails.logger.info("[AppAttest] authenticator_data hex: #{authenticator_data.unpack1('H*')}")

        raise VerificationError, "signature verification failed"
      end
    end

    # Extract and verify sign count
    parsed = parse_assertion_auth_data(authenticator_data)
    new_sign_count = parsed[:sign_count]

    # Use row-level lock to prevent concurrent sign_count race conditions
    credential.with_lock do
      if new_sign_count <= credential.sign_count
        raise VerificationError, "sign_count not incremented (replay attack?)"
      end
      credential.update!(sign_count: new_sign_count)
    end

    true
  end

  private

  def verify_certificate_chain(leaf_cert, intermediate_certs)
    root_ca_pem = File.read(APPLE_APP_ATTEST_ROOT_CA_PATH)
    root_ca = OpenSSL::X509::Certificate.new(root_ca_pem)

    Rails.logger.info("[AppAttest] Root CA subject: #{root_ca.subject}")
    Rails.logger.info("[AppAttest] Root CA issuer: #{root_ca.issuer}")
    Rails.logger.info("[AppAttest] Leaf cert subject: #{leaf_cert.subject}")
    Rails.logger.info("[AppAttest] Leaf cert issuer: #{leaf_cert.issuer}")
    Rails.logger.info("[AppAttest] Intermediate certs count: #{intermediate_certs.size}")
    intermediate_certs.each_with_index do |cert, i|
      Rails.logger.info("[AppAttest] Intermediate[#{i}] subject: #{cert.subject}")
      Rails.logger.info("[AppAttest] Intermediate[#{i}] issuer: #{cert.issuer}")
    end

    store = OpenSSL::X509::Store.new
    store.add_cert(root_ca)

    # Also add Apple Root CA - G3 (some attestation chains use this root)
    g3_loaded = false
    if File.exist?(APPLE_ROOT_CA_G3_PATH)
      root_ca_g3 = OpenSSL::X509::Certificate.new(File.read(APPLE_ROOT_CA_G3_PATH))
      store.add_cert(root_ca_g3)
      g3_loaded = true
      Rails.logger.info("[AppAttest] G3 Root CA loaded, subject: #{root_ca_g3.subject}")
    else
      Rails.logger.warn("[AppAttest] G3 Root CA file NOT FOUND at #{APPLE_ROOT_CA_G3_PATH}")
    end

    intermediate_certs.each { |cert| store.add_cert(cert) }

    unless store.verify(leaf_cert)
      Rails.logger.error("[AppAttest] Verify failed: #{store.error_string} (error code: #{store.error})")
      Rails.logger.error("[AppAttest] G3 loaded: #{g3_loaded}, store certs: root + #{intermediate_certs.size} intermediates")
      raise VerificationError, "certificate chain verification failed: #{store.error_string}"
    end

    Rails.logger.info("[AppAttest] Certificate chain verified successfully")
  end

  def extract_nonce_from_cert(cert)
    # OID 1.2.840.113635.100.8.2 contains the nonce
    nonce_oid = "1.2.840.113635.100.8.2"
    ext = cert.extensions.find { |e| e.oid == nonce_oid }
    raise VerificationError, "nonce extension not found in certificate" unless ext

    # The value is ASN.1 encoded: SEQUENCE { SEQUENCE { [1] OCTET_STRING(nonce) } }
    asn1 = OpenSSL::ASN1.decode(ext.value_der)
    # Navigate the ASN.1 structure to get the nonce
    asn1.value.first.value.first.value
  rescue => e
    raise VerificationError, "failed to extract nonce: #{e.message}"
  end

  def parse_authenticator_data(data)
    # https://www.w3.org/TR/webauthn/#authenticator-data
    rp_id_hash = data[0, 32]
    flags = data[32].unpack1("C")
    sign_count = data[33, 4].unpack1("N")

    result = { rp_id_hash: rp_id_hash, flags: flags, sign_count: sign_count }

    # If attested credential data is present (bit 6 of flags)
    if (flags & 0x40) != 0
      aaguid = data[37, 16]
      credential_id_length = data[53, 2].unpack1("n")
      credential_id = data[55, credential_id_length]

      result[:aaguid] = aaguid
      result[:credential_id] = credential_id
      result[:credential_id_length] = credential_id_length
    end

    result
  end

  def parse_assertion_auth_data(data)
    # Assertion authenticator data is simpler: rpIdHash(32) + flags(1) + signCount(4)
    {
      rp_id_hash: data[0, 32],
      flags: data[32].unpack1("C"),
      sign_count: data[33, 4].unpack1("N")
    }
  end
end
