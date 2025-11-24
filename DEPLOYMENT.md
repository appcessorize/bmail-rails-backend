# Deploying Blackmail Focus Backend to Coolify

## Prerequisites

1. Coolify instance running
2. GitHub/GitLab repository connected to Coolify
3. PostgreSQL database service in Coolify

## Deployment Steps

### 1. Create New Application in Coolify

1. Go to your Coolify dashboard
2. Click **+ New Resource** → **Application**
3. Select your Git repository
4. Choose **Nixpacks** as the build pack
5. Set the **Root Directory** to `bmbackend-rails` (if in monorepo)

### 2. Add PostgreSQL Database

1. In Coolify, go to **Resources** → **+ New**
2. Select **PostgreSQL**
3. Note the connection details (or Coolify will auto-inject `DATABASE_URL`)

### 3. Configure Environment Variables

In Coolify's Environment Variables section, add:

```bash
# Required
RAILS_ENV=production
SECRET_KEY_BASE=<generate with: bin/rails secret>
ALLOWED_ORIGINS=https://your-domain.com
ALLOWED_HOSTS=your-domain.com

# Optional (if not auto-injected by Coolify)
DATABASE_URL=postgresql://user:pass@host:5432/dbname
BMBACKEND_RAILS_DATABASE_PASSWORD=<your_db_password>

# Rails Config
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
RAILS_MAX_THREADS=5
```

### 4. Generate SECRET_KEY_BASE

Run locally to generate a secret key:
```bash
cd bmbackend-rails
bin/rails secret
```
Copy the output and add it to Coolify environment variables.

### 5. Configure Domain

1. In Coolify, go to **Domains** tab
2. Add your domain (e.g., `api.your-domain.com`)
3. Enable SSL (Coolify auto-provisions Let's Encrypt)

### 6. Deploy

1. Click **Deploy** button in Coolify
2. Monitor the build logs
3. Nixpacks will:
   - Install dependencies (`bundle install`)
   - Run migrations (`db:prepare`)
   - Start the server on port 3000

### 7. Verify Deployment

Test endpoints:
```bash
# Health check
curl https://your-domain.com/up

# Signup test
curl -X POST https://your-domain.com/signup \
  -H "Content-Type: application/json" \
  -d '{"user":{"username":"test","email":"test@example.com","password":"password123","password_confirmation":"password123"}}'
```

## Important Security Notes

### 1. Update ALLOWED_ORIGINS
Set to your frontend domain(s):
```bash
ALLOWED_ORIGINS=https://app.your-domain.com,https://your-domain.com
```

### 2. Update ALLOWED_HOSTS
Set to your API domain:
```bash
ALLOWED_HOSTS=api.your-domain.com
```

### 3. File Storage (Optional)
For production file storage, configure S3:
1. Edit `config/storage.yml`
2. Add environment variables:
   ```bash
   AWS_ACCESS_KEY_ID=your_key
   AWS_SECRET_ACCESS_KEY=your_secret
   AWS_REGION=us-east-1
   AWS_BUCKET=your-bucket
   ```
3. Update `config/environments/production.rb`:
   ```ruby
   config.active_storage.service = :amazon
   ```

## Database Migrations

Migrations run automatically on deploy via `db:prepare` in nixpacks.toml.

To run manually:
```bash
# In Coolify terminal
bin/rails db:migrate
```

## Monitoring Logs

In Coolify:
1. Go to your app
2. Click **Logs** tab
3. View real-time logs

Look for security audit events:
```json
{"event":"security_audit","type":"login_success","user_id":1,"ip":"..."}
{"event":"security_audit","type":"image_uploaded","user_id":1,"ip":"..."}
```

## Rate Limiting

Current limits (configured in `config/initializers/rack_attack.rb`):
- Login attempts: 5 per minute per username
- Signups: 3 per 5 minutes per IP
- Image uploads: 10 per minute per IP
- General requests: 300 per minute per IP

## Troubleshooting

### Build Fails
- Check Ruby version matches (3.4.4 in `.ruby-version`)
- Verify `bundle install` completes successfully
- Check database connection

### Database Connection Issues
- Verify `DATABASE_URL` is set
- Check PostgreSQL service is running in Coolify
- Ensure database exists

### CORS Errors
- Update `ALLOWED_ORIGINS` to include your frontend domain
- Ensure domain includes protocol (https://)

### 500 Errors
- Check Coolify logs for stack traces
- Verify all environment variables are set
- Run `bin/rails credentials:edit` if using encrypted credentials

## Updating the App

1. Push changes to Git repository
2. Coolify will auto-deploy (if auto-deploy enabled)
3. Or manually click **Redeploy** in Coolify

## Rollback

In Coolify:
1. Go to **Deployments** tab
2. Find previous successful deployment
3. Click **Redeploy** on that version
