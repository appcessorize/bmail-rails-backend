# R2 Migration Checklist

All code changes are in place. Complete the manual steps below to go live with Cloudflare R2 storage.

---

## 1. Cloudflare R2 Setup

- [ ] Create an R2 bucket in the Cloudflare dashboard (note the bucket name)
- [ ] Note your **Cloudflare Account ID** (visible in the dashboard URL or Overview page)
- [ ] Create an **R2 API token** with read/write permissions for the bucket
  - Save the **Access Key ID** and **Secret Access Key**
- [ ] Configure CORS on the bucket (Settings > CORS Policy):
  - Allowed origins: `https://blackmail.wtf`, `https://api.blackmail.wtf`
  - Allowed methods: `GET`, `PUT`
  - Allowed headers: `*`
  - Max age: `3600`

## 2. Rails Credentials / Coolify Env

The app reads R2 config from **Rails encrypted credentials** under the `:r2` key (see `config/storage.yml`).

- [ ] Edit credentials (`EDITOR=nano bin/rails credentials:edit`) and add:
  ```yaml
  r2:
    access_key_id: <your-access-key-id>
    secret_access_key: <your-secret-access-key>
    bucket: <your-bucket-name>
    account_id: <your-cloudflare-account-id>
  ```
- [ ] If using Coolify env vars instead of encrypted credentials, set:
  - `RAILS_MASTER_KEY` (so the app can decrypt credentials), **or**
  - Adapt `config/storage.yml` to read from `ENV` and set `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET`, `R2_ACCOUNT_ID`
- [ ] Verify `config/environments/production.rb` has `config.active_storage.service = :cloudflare_r2` (already set)

## 3. Deploy & Migrate

- [ ] Deploy the updated code to production
- [ ] Run the storage migration rake task to copy existing local blobs to R2:
  ```sh
  bin/rails storage:migrate_to_r2
  ```
- [ ] Confirm the task output shows all blobs migrated (check for failures)
- [ ] Once verified, remove or archive the local `storage/` directory contents

## 4. Verification

- [ ] **Upload test** — upload a profile image and confirm it lands in the R2 bucket
- [ ] **Shame page image** — view a shame page (`/p/:slug`) and confirm the image loads via `/p/:slug/image` redirect
- [ ] **Private image test** — fetch an image through the images controller and confirm 5-min signed URL works
- [ ] **Blocked routes** — confirm default ActiveStorage routes are still disabled (`draw_routes = false` in `config/application.rb`)
- [ ] **Rate limits** — verify upload throttling still works (10 req / 60s on `/upload_image`)
- [ ] **File validation** — try uploading a non-image file and confirm it's rejected (JPEG/PNG/GIF only, 5 MB max)

---

Once all boxes are checked, R2 is fully live.
