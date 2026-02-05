<#
deploy-railway.ps1

Usage:
  Open PowerShell in the project root and run:
    .\deploy-railway.ps1 -Branch add-mongodb-extension

Environment:
  - Ensure `git`, `docker` are installed locally.
  - To auto-deploy, install the Railway CLI and run `railway login` beforehand,
    or run `railway up` interactively when prompted.

What it does:
  1. Creates/switches to branch, commits Dockerfile changes, and pushes to origin.
  2. Builds the Docker image locally and checks for the `mongodb` PHP extension.
  3. Runs `composer install` inside the official Composer image to verify dependencies.
  4. If `railway` CLI is installed, runs `railway up --branch <branch>` to deploy.
#>

param(
    [string]$Branch = "add-mongodb-extension",
    [string]$RailwayToken = $null
)

function Run($cmd) {
    Write-Host "Running: $cmd"
    $proc = Start-Process -FilePath 'powershell' -ArgumentList "-NoProfile -Command $cmd" -NoNewWindow -Wait -PassThru
    return $proc.ExitCode
}

Write-Host "1) Preparing git branch: $Branch"

# Create or switch to branch
if ((git rev-parse --verify $Branch) -ne $null) {
    git checkout $Branch
} else {
    git checkout -b $Branch
}

# Stage Dockerfiles and commit (if any changes)
git add Dockerfile Dockerfile/Dockerfile
$commitMsg = 'Install ext-mongodb (pecl) in Dockerfile for Railway builds'
try {
    git commit -m "$commitMsg"
} catch {
    Write-Host "No changes to commit or commit failed: $_" -ForegroundColor Yellow
}

Write-Host "Pushing branch to origin..."
git push -u origin $Branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "git push failed. Please check remote/credentials." -ForegroundColor Red
    exit 1
}

Write-Host "2) Building Docker image locally to verify MongoDB extension"
$imageTag = "internship-project:test"
docker build -t $imageTag .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed. Fix Dockerfile then re-run." -ForegroundColor Red
    exit 1
}

Write-Host "Checking for mongodb extension inside container (php -m)"
docker run --rm $imageTag php -m | Select-String -Pattern "mongodb" | ForEach-Object { Write-Host $_ }
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: mongodb extension not found in container output." -ForegroundColor Yellow
    Write-Host "Continue to push/deploy, but Composer may still fail on remote builds." -ForegroundColor Yellow
}

Write-Host "3) Running composer install using official composer image (verifies dependencies)"
docker run --rm -v ${PWD}:/app -w /app composer:2 composer install --optimize-autoloader --no-scripts --no-interaction
if ($LASTEXITCODE -ne 0) {
    Write-Host "Composer reported errors. Inspect above output. If missing ext-mongodb, the remote build must install the extension." -ForegroundColor Red
}

Write-Host "4) Deploying to Railway (if Railway CLI is installed)"
if (Get-Command railway -ErrorAction SilentlyContinue) {
    if ($RailwayToken) {
        Write-Host "Setting RAILWAY_TOKEN environment variable (persistent)"
        setx RAILWAY_TOKEN $RailwayToken | Out-Null
        $env:RAILWAY_TOKEN = $RailwayToken
    }

    Write-Host "Railway CLI found. Running: railway up --branch $Branch"
    railway up --branch $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Railway deploy failed. Run 'railway up' interactively or check Railway project link." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Railway CLI not installed. Install it and run 'railway login' then: railway up --branch $Branch" -ForegroundColor Yellow
    Write-Host "To install: npm install -g @railway/cli" -ForegroundColor Yellow
}

Write-Host "Done. Check Railway build logs to confirm ext-mongodb installed and composer succeeded." -ForegroundColor Green
