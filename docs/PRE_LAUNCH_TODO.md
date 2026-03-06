# Pre-Launch TODO

## App Attest Enforcement

App Attest is deployed but **disabled** (`REQUIRE_APP_ATTEST=false`). Before enabling:

- [ ] Submit app to TestFlight
- [ ] Test attestation on a physical device — verify server logs show successful attestation after login
- [ ] Verify assertion headers (`X-App-Key-Id`, `X-App-Assertion`) appear on API requests
- [ ] Test stolen token rejection: copy a bearer token and curl an endpoint → should get 403 when attest is enabled
- [ ] Set Coolify env vars:
  - `APPLE_TEAM_ID=984MA3M975`
  - `APPLE_BUNDLE_ID=com.expomang.Blackmail-Focus-or-else`
- [ ] Flip `REQUIRE_APP_ATTEST=true` in Coolify environment variables
- [ ] Monitor server logs for `attestation_failed` events

## Token Refresh

Already active. Access tokens now expire in 1 hour (was 7 days). Refresh tokens last 30 days.

- [ ] Verify automatic token refresh works — leave app open for >1 hour, confirm API calls still succeed
- [ ] Verify logout clears both access and refresh tokens
