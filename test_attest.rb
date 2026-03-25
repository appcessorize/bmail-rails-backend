require "openssl"
require "digest"

puts "OpenSSL: #{OpenSSL::OPENSSL_VERSION}"
puts "Ruby OpenSSL gem: #{OpenSSL::VERSION}"

pub_hex = "3059301306072a8648ce3d020106082a8648ce3d030107034200" \
          "04a1a1da945df2fecc93f2e72823e80a9b15da6a81874682ef" \
          "cc1f926787631cf1aedd59daca28b3f7215ee6598c5ae02999" \
          "fa47387102cdcf8c4bcd00c80d5de1"

sig_hex = "3045022100a6acddd9778f00127cd52f5e8bf8a948e56e31d4" \
          "656aa05837156d837c51e3ce0220115b47700976bf57bea90b" \
          "c2463a0a2693f417442afbbd6ea142cf2ba3b681c5"

auth_hex = "e411955b8d250d3606b5044e98539d28f67102beca326e52" \
           "8b554712458db6664000000001"

cdh_hex = "431ce8d47e67844ed833a33d619495255145a8c952349ff2" \
          "a724e65e48073900"

pub_der = [pub_hex].pack("H*")
sig = [sig_hex].pack("H*")
auth = [auth_hex].pack("H*")
cdh = [cdh_hex].pack("H*")
msg = auth + cdh

puts "pub_der size: #{pub_der.bytesize}"
puts "sig size: #{sig.bytesize}"
puts "msg size: #{msg.bytesize}"

begin
  key = OpenSSL::PKey.read(pub_der)
  puts "Key loaded: #{key.class}"

  result = key.verify("SHA256", sig, msg)
  puts "verify(SHA256): #{result}"

  hash = Digest::SHA256.digest(msg)
  result2 = key.dsa_verify_asn1(hash, sig) rescue $!.to_s
  puts "dsa_verify_asn1: #{result2}"
rescue => e
  puts "ERROR: #{e.class} #{e.message}"
end
