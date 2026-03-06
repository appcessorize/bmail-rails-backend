# App Attest + Token Refresh — How It Works

## Overview

App Attest is Apple's device attestation framework that cryptographically proves each API request comes from a **real, unmodified copy of your app running on a genuine Apple device**. Combined with token refresh, this makes stolen bearer tokens useless without physical access to the device.

## The Problem It Solves

Without App Attest, anyone who obtains a bearer token (via network sniffing, device backup extraction, etc.) can call your API from scripts, curl, or modified apps. App Attest makes the Secure Enclave on the device sign every request — so even a valid token is rejected if the request wasn't made from the real app.

## How It Works

### One-Time Attestation (after login)

```
┌──────────┐                    ┌──────────┐                    ┌─────────┐
│   App    │                    │  Server  │                    │  Apple  │
└────┬─────┘                    └────┬─────┘                    └────┬────┘
     │                               │                               │
     │  1. Generate key pair         │                               │
     │  (Secure Enclave)             │                               │
     │                               │                               │
     │  2. GET /attest/challenge ──> │                               │
     │  <── nonce ──────────────────│                               │
     │                               │                               │
     │  3. attestKey(keyId, hash) ──────────────────────────────────>│
     │  <── attestation object (signed by Apple) ───────────────────│
     │                               │                               │
     │  4. POST /attest ───────────>│                               │
     │     { key_id,                 │  5. Verify:                   │
     │       attestation_object,     │     - Certificate chain       │
     │       challenge }             │       → Apple Root CA         │
     │                               │     - Nonce matches           │
     │                               │     - App ID correct          │
     │                               │     - Extract public key      │
     │                               │     - Store credential        │
     │  <── { status: "attested" } ─│                               │
```

**What happens:** The Secure Enclave generates a key pair that never leaves the device. Apple signs a certificate confirming this key belongs to your real app on a real device. The server verifies Apple's signature and stores the public key.

### Per-Request Assertions (every API call)

```
┌──────────┐                    ┌──────────┐
│   App    │                    │  Server  │
└────┬─────┘                    └────┬─────┘
     │                               │
     │  1. Build canonical string:   │
     │     "GET /me <body_sha256>"   │
     │                               │
     │  2. Secure Enclave signs it   │
     │     (5-15ms, negligible)      │
     │                               │
     │  3. API request ────────────>│
     │     Authorization: Bearer ... │
     │     X-App-Key-Id: <key_id>    │  4. Look up stored public key
     │     X-App-Assertion: <sig>    │  5. Verify signature
     │                               │  6. Check sign_count (replay)
     │  <── normal response ────────│
```

**What happens:** Every API request is signed by the Secure Enclave. The server verifies the signature matches the stored public key. A monotonic counter (`sign_count`) prevents replay attacks.

### Why Stolen Tokens Are Useless

| Attack | Without App Attest | With App Attest |
|--------|-------------------|-----------------|
| Copy bearer token to curl | Full API access | 403 Forbidden (no assertion) |
| Modified/jailbroken app | Works normally | Attestation fails (Apple won't certify) |
| Replay captured request | Works if token valid | 403 (sign_count already used) |
| Token from device backup | Works | 403 (Secure Enclave key doesn't transfer) |

## Token Refresh

Previously: 7-day bearer tokens with no rotation.
Now: **1-hour access tokens** + **30-day refresh tokens** with automatic rotation.

```
┌──────────┐                    ┌──────────┐
│   App    │                    │  Server  │
└────┬─────┘                    └────┬─────┘
     │                               │
     │  API request ───────────────>│
     │  <── 401 (token expired) ───│
     │                               │
     │  POST /auth/refresh ────────>│
     │  { refresh_token: "..." }     │  Verify refresh token
     │                               │  Generate new access + refresh
     │  <── { auth_token,           │  (old refresh token invalidated)
     │        refresh_token } ──────│
     │                               │
     │  Retry original request ────>│
     │  <── 200 OK ────────────────│
```

**Key points:**
- Access tokens expire in 1 hour (limits damage window if stolen)
- Refresh tokens rotate on each use (one-time use)
- If refresh token is stolen and used by attacker, legit user's next refresh fails → forces re-login (detection)
- Logout invalidates both tokens server-side

## Environment Configuration

### Server (env vars)

| Variable | Purpose | Default |
|----------|---------|---------|
| `REQUIRE_APP_ATTEST` | Enable assertion verification | `"false"` |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID | `""` |
| `APPLE_BUNDLE_ID` | App bundle identifier | `""` |

### Client (automatic)

- `DCAppAttestService.shared.isSupported` returns `false` on simulator → attestation skipped
- On real devices, attestation happens automatically after login
- Dev builds use Apple's development environment (`appattestdevelop` aaguid)

## Enabling in Production

### Pre-launch checklist

1. Set env vars on Coolify:
   - `APPLE_TEAM_ID=984MA3M975`
   - `APPLE_BUNDLE_ID=com.expomang.Blackmail-Focus-or-else`
   - `REQUIRE_APP_ATTEST=false` (keep false initially)

2. Run database migration:
   ```bash
   rails db:migrate
   ```

3. Deploy backend + submit app to TestFlight

4. Test on a physical device:
   - Login → check server logs for successful attestation
   - Make API calls → check assertion headers are being sent
   - Try curl with stolen token → should get 403

5. Once verified, flip `REQUIRE_APP_ATTEST=true`

### Rollback

If something goes wrong, set `REQUIRE_APP_ATTEST=false` — all requests will be accepted again immediately, no app update needed.

## File Reference

### Frontend
- `AttestationManager.swift` — Singleton wrapping DCAppAttestService (key gen, attestation, per-request assertion)
- `KeychainHelper.swift` — Stores `attestKeyId`, `attestationCompleted`, `refreshToken`, `refreshTokenExpiresAt`
- `AppCore.swift` — `performRequest()` wrapper attaches assertions + handles token refresh

### Backend
- `app/services/app_attest_verification_service.rb` — CBOR parsing, certificate chain verification, signature verification
- `app/controllers/attestations_controller.rb` — `GET /attest/challenge` + `POST /attest`
- `app/controllers/application_controller.rb` — `verify_app_attest!` before_action
- `app/models/app_attest_credential.rb` — Stores public key + sign_count per device
- `config/certs/Apple_App_Attestation_Root_CA.pem` — Apple's root CA for certificate chain verification
