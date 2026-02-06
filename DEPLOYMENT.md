# Deployment Solution for MongoDB Support on Railway

## Summary
The project now has full support for MongoDB PHP driver (`ext-mongodb`) which is required by the `mongodb/mongodb` Composer package. The Dockerfile has been completely redesigned to use a production-ready architecture.

## Architecture
- **Base Image**: `php:8.2-fpm` (PHP FastCGI Process Manager)
- **Web Server**: Nginx (reverse proxy to PHP-FPM)
- **PHP Extensions**: 
  - `mongodb` (PECL package for MongoDB driver)
  - `pdo` 
  - `pdo_mysql`
- **OS Dependencies**: libssl-dev, pkg-config (required for PECL compilation)

## Why This Approach?
The original `php:8.2-apache` base image caused Apache MPM (Multi-Processing Module) conflicts that prevented the container from starting. The new architecture uses:

1. **PHP-FPM** - Separates PHP execution from web server logic
2. **Nginx** - Lightweight, no MPM conflicts, fast reverse proxy
3. **Separate processes** - PHP-FPM runs independently, Nginx proxies requests to it

## Key Changes Made
1. **Dockerfile** - Now builds an Nginx + PHP-FPM container with MongoDB support
2. **railway.json** - Configured to use Dockerfile builder instead of Railpack
3. **test.php** - Created to verify extensions are properly loaded
4. **No MPM conflicts** - By using FPM + Nginx instead of Apache mod_php

## Deployment Steps

### To Railway
```bash
# The branch `add-mongodb-extension` contains all fixes
git checkout add-mongodb-extension
git push origin add-mongodb-extension

# Deploy to Railway
railway up

# Check logs
railway logs
```

### To Docker Locally
```bash
docker build -t internship-app:latest .
docker run -d -p 80:80 internship-app:latest
```

### To Other Platforms
The Dockerfile should work on any platform that supports Docker:
- Docker Hub
- AWS ECS
- Google Cloud Run
- Azure Container Instances
- DigitalOcean App Platform
- Render
- Heroku

## Verification
Once deployed, visit your service URL and navigate to `/test.php` to verify:
- MongoDB extension is loaded
- PDO MySQL extension is loaded
- PHP version and server information

## Composer Installation
With `ext-mongodb` now available, Composer will successfully install the `mongodb/mongodb` package:
```bash
composer install --optimize-autoloader --no-scripts --no-interaction
```

## Important Notes
- The MongoDB extension takes ~2-3 minutes to compile during first build
- Subsequent deployments are much faster (uses Docker layer cache)
- PHP-FPM and Nginx are started together via the CMD instruction
- No separate entrypoint wrapper is needed

## Next Steps
1. Ensure Railway service is operational (was experiencing issues)
2. Run `railway up` on the `add-mongodb-extension` branch
3. Verify `test.php` loads without errors
4. Run Composer to install dependencies
5. Deploy to production

## Troubleshooting
- **502 errors**: Check that both PHP-FPM and Nginx started successfully
- **MongoDB not loading**: Ensure build completed without errors (check build logs)
- **Composer still fails**: Run `test.php` to verify extension is available
- **Port issues**: Ensure port 80 is properly exposed and mapped

## References
- [MongoDB PHP Driver](https://www.php.net/manual/en/book.mongodb.php)
- [Nginx + PHP-FPM Setup](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-nginx-with-php-fpm-on-ubuntu-20-04)
- [Railway Dockerfile Support](https://docs.railway.app/deploy/dockerfiles)
