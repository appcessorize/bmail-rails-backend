# Security Audit - Blackmail.wtf Rails Backend

**Date:** 2026-02-27
**Auditor:** Claude Code
**Scope:** Full backend security review + test coverage assessment

---

## Summary

The Blackmail.wtf Rails backend has solid foundations (bcrypt, token digests, account lockout, rate limiting on key endpoints). However, 12 security issues were found across critical, high, and medium severity levels, plus zero test coverage.

**Positive practices already in place:**
- bcrypt for password hashing via `has_secure_password`
- Token digest stored via SHA256 (not raw token)
- Token expiration (7 days)
- Account lockout after 5 failed attempts (15-minute duration)
- Rate limiting on login, signup, and upload endpoints
- JWT verification for Apple Sign-In
- SSL enforcement in production (`force_ssl = true`)
- Security headers configured
- CORS restricted by environment
- Parameter filtering in logs
- Image file size limits (5MB max)

---

## Critical Issues

### 1. Hardcoded Default Admin Token
- [x] **Fixed**

**File:** `app/controllers/contacts_controller.rb:64`

**Current code:**
```ruby
request.headers["X-Admin-Token"] == ENV.fetch("ADMIN_TOKEN", "change-me-in-production")
```

**Problem:** If `ADMIN_TOKEN` env var is unset, the literal string `"change-me-in-production"` becomes the valid admin token. Anyone can access `GET /admin/contacts` and read all contact submissions.

**Fix:** Remove the fallback. Deny access if env var is missing. Add rate limiting on admin endpoint.
```ruby
def admin_authorized?
  token = ENV["ADMIN_TOKEN"]
  token.present? && ActiveSupport::SecurityUtils.secure_compare(request.headers["X-Admin-Token"].to_s, token)
end
```

---

### 2. Stored XSS in Contact Form Error Messages
- [x] **Fixed**

**File:** `app/controllers/contacts_controller.rb:107-112`

**Current code:**
```ruby
def contact_form_html(errors = [])
  error_html = if errors.any?
    "<div class='error-box'>#{errors.map { |e| "<p>#{e}</p>" }.join}</div>"
  else
    ""
  end
```

**Problem:** Validation error messages are interpolated directly into HTML without escaping, then marked `.html_safe`. If any error message contains user-controlled content (e.g., email field echoed back in validation), it becomes an XSS vector.

**Fix:** HTML-escape all error messages:
```ruby
"<div class='error-box'>#{errors.map { |e| "<p>#{CGI.escapeHTML(e)}</p>" }.join}</div>"
```

---

### 3. Telegram HTML Injection
- [x] **Fixed**

**File:** `app/controllers/contacts_controller.rb:52-53`

**Current code:**
```ruby
uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")
Net::HTTP.post_form(uri, chat_id: chat_id, text: message, parse_mode: "HTML")
```

**Problem:** User-supplied `contact.email` and `contact.message` are interpolated into the Telegram message with `parse_mode: "HTML"`. An attacker can inject Telegram HTML formatting tags (`<b>`, `<a href="...">`, etc.) to craft phishing links or misleading messages sent to the admin's Telegram.

**Fix:** Remove `parse_mode: "HTML"` to send as plain text:
```ruby
Net::HTTP.post_form(uri, chat_id: chat_id, text: message)
```

---

### 4. No Rate Limiting on Contact Form
- [x] **Fixed**

**File:** `config/initializers/rack_attack.rb`

**Problem:** `POST /contact` has no rate limiting. Login (5/min), signup (3/5min), and upload (10/min) are all throttled, but the contact form is wide open. An attacker can spam thousands of contact submissions, flooding the database and triggering Telegram notifications.

**Fix:** Add throttle rule:
```ruby
throttle("contact/ip", limit: 5, period: 300) do |req|
  if req.path == "/contact" && req.post?
    req.ip
  end
end
```

---

## High Issues

### 5. Weak Password Requirements
- [x] **Fixed**

**File:** `app/models/user.rb:19`

**Current code:**
```ruby
validates :password, length: { minimum: 8 }, if: -> { password.present? && apple_user_id.blank? }
```

**Problem:** Password can be 8 identical lowercase letters (`aaaaaaaa`). No requirements for uppercase, digits, or special characters.

**Fix:** Add a custom validation for password complexity:
```ruby
validate :password_complexity, if: -> { password.present? && apple_user_id.blank? }

def password_complexity
  return if password.blank?
  unless password.match?(/[a-z]/) && password.match?(/[A-Z]/) && password.match?(/\d/)
    errors.add(:password, "must include at least one lowercase letter, one uppercase letter, and one digit")
  end
end
```

---

### 6. Entry Model Missing Body Validation
- [x] **Fixed**

**File:** `app/models/entry.rb`

**Current code:**
```ruby
class Entry < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
end
```

**Problem:** No validation on `body`. Users can create entries with empty/nil body, allowing database pollution and potential resource exhaustion.

**Fix:** Add body presence validation:
```ruby
validates :body, presence: true
```

---

### 7. Admin Endpoint Not Rate-Limited (Brute Force)
- [x] **Fixed**

**File:** `config/initializers/rack_attack.rb` + `app/controllers/contacts_controller.rb`

**Problem:** `GET /admin/contacts` uses a simple header token with no rate limiting. An attacker can brute-force the token with unlimited attempts per minute.

**Fix:** Add throttle for admin endpoint:
```ruby
throttle("admin/ip", limit: 5, period: 60) do |req|
  if req.path.start_with?("/admin")
    req.ip
  end
end
```

---

## Medium Issues

### 8. Username Enumeration via Login Response
- [x] **Acknowledged** (Known trade-off)

**File:** `app/controllers/sessions_controller.rb:18,72-75`

**Current code:**
```ruby
# 404 for user not found
render json: { error: "user_not_found" }, status: :not_found
# 401 for wrong password with attempts_remaining
render json: { error: "invalid_password", attempts_remaining: ... }, status: :unauthorized
```

**Problem:** Different HTTP status codes (404 vs 401) and error messages reveal whether a username exists. Attackers can enumerate valid usernames.

**Note:** This is intentional for the SwiftUI client UX (showing "sign up" vs "wrong password"). Documenting as a known trade-off. The account lockout and login rate limiting mitigate the risk.

**Status:** Known trade-off - mitigated by existing rate limiting and lockout.

---

### 9. Apple Sign-In Error Message Leakage
- [x] **Fixed**

**File:** `app/controllers/sessions_controller.rb:154`

**Current code:**
```ruby
render json: { error: "Apple sign in failed: #{e.message}" }, status: :unauthorized
```

**Problem:** Internal error details from Apple's JWT verification are exposed to the client, revealing implementation details.

**Fix:** Return generic error message:
```ruby
render json: { error: "Apple sign in failed" }, status: :unauthorized
```

---

### 10. Focus Session Duration No Upper Bound
- [x] **Fixed**

**File:** `app/models/focus_session.rb:4`

**Current code:**
```ruby
validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
```

**Problem:** No maximum limit. A user could set `duration_minutes` to `999999999`, causing potential integer overflow or excessive resource use.

**Fix:** Add upper bound:
```ruby
validates :duration_minutes, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 480 }
```

---

### 11. ALLOWED_HOSTS Default Includes localhost
- [x] **Fixed**

**File:** `config/environments/production.rb:79`

**Current code:**
```ruby
config.hosts = ENV.fetch("ALLOWED_HOSTS", "blackmail.wtf,api.blackmail.wtf,localhost").split(",").map(&:strip)
```

**Problem:** If `ALLOWED_HOSTS` env var is unset in production, `localhost` is in the allowed hosts list, potentially enabling Host header injection.

**Fix:** Remove `localhost` from the default:
```ruby
config.hosts = ENV.fetch("ALLOWED_HOSTS", "blackmail.wtf,api.blackmail.wtf").split(",").map(&:strip)
```

---

### 12. Content-Type Validation Relies on Client Headers
- [ ] **Acknowledged**

**File:** `app/models/user.rb:125`

**Current code:**
```ruby
unless profile_image.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
```

**Problem:** `content_type` is set from the client request header, which can be spoofed. An attacker could upload a non-image file with a fake content-type header.

**Mitigation:** Rails Active Storage does perform some server-side validation. The 5MB file size limit reduces risk. Full fix would require magic-number validation (e.g., `ruby-vips`), which is a larger change.

**Status:** Low risk given existing mitigations. Tracked for future improvement.

---

## Test Coverage Gaps

### Current State
All test files are empty stubs with zero assertions:
- `test/models/user_test.rb` - empty
- `test/models/entry_test.rb` - empty
- `test/controllers/sessions_controller_test.rb` - empty
- `test/controllers/users_controller_test.rb` - empty
- `test/controllers/entries_controller_test.rb` - empty
- No tests for: `ContactsController`, `FocusSessionsController`, `ShamePagesController`
- No tests for: `Contact` model, `FocusSession` model

### Required Test Coverage
- [x] **Fixtures** - Proper user/entry/contact/focus_session fixtures
- [x] **Model tests** - User, Entry, Contact, FocusSession validations
- [x] **Controller tests** - All endpoints with auth and error cases
- [x] **Security tests** - XSS, injection, auth bypass, rate limiting

---

## SwiftUI Client Security Assessment

The SwiftUI client communicates with this backend via:
- `Authorization: Bearer <token>` header for authenticated requests
- Token stored in iOS Keychain (secure)
- Apple Sign-In via identity token verification

**Observations:**
- The client relies on distinct error codes (`user_not_found` vs `invalid_password`) for UX flow decisions - this is why username enumeration (Issue #8) is a known trade-off
- Token expiration is 7 days, which is reasonable for a mobile app
- The raw `auth_token` is returned once on login/signup and never stored server-side (only the digest) - this is correct

---

## Fix Tracking

| # | Severity | Issue | Status |
|---|----------|-------|--------|
| 1 | CRITICAL | Admin token fallback | FIXED |
| 2 | CRITICAL | XSS in error messages | FIXED |
| 3 | CRITICAL | Telegram HTML injection | FIXED |
| 4 | CRITICAL | Contact form rate limiting | FIXED |
| 5 | HIGH | Weak password requirements | FIXED |
| 6 | HIGH | Entry missing body validation | FIXED |
| 7 | HIGH | Admin endpoint brute force | FIXED |
| 8 | MEDIUM | Username enumeration | Known trade-off |
| 9 | MEDIUM | Apple error leakage | FIXED |
| 10 | MEDIUM | Focus session duration bound | FIXED |
| 11 | MEDIUM | ALLOWED_HOSTS localhost | FIXED |
| 12 | MEDIUM | Content-type spoofing | Acknowledged |
