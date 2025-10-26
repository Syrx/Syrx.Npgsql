# Syrx PostgreSQL Test Database Docker Build Script

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("build", "up", "down", "restart", "logs", "status", "clean", "test")]
    [string]$Action = "build",
    
    [Parameter(Mandatory=$false)]
    [switch]$Follow,
    
    [Parameter(Mandatory=$false)]
    [switch]$RemoveVolumes
)

$ErrorActionPreference = "Stop"

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "Syrx PostgreSQL Test Database Docker Management" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

switch ($Action) {
    "build" {
        Write-Host "Building Syrx PostgreSQL test image..." -ForegroundColor Yellow
        
        # Build the custom Docker image
        docker build -t docker-syrx-postgres-test:latest .
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Build completed successfully!" -ForegroundColor Green
            Write-Host "Image 'docker-syrx-postgres-test:latest' is ready for use with TestContainers" -ForegroundColor Cyan
        } else {
            Write-Host "Build failed!" -ForegroundColor Red
            exit 1
        }
    }
    
    "up" {
        Write-Host "Starting Syrx PostgreSQL test container via docker-compose..." -ForegroundColor Yellow
        docker-compose up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Container started successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Connection Details:" -ForegroundColor Cyan
            Write-Host "  Host: localhost" -ForegroundColor White
            Write-Host "  Port: 5432" -ForegroundColor White
            Write-Host "  Database: syrx" -ForegroundColor White
            Write-Host "  Username: syrx_user" -ForegroundColor White
            Write-Host "  Password: YourStrong!Passw0rd" -ForegroundColor White
            Write-Host ""
            Write-Host "Connection String:" -ForegroundColor Cyan
            Write-Host "  Host=localhost;Port=5432;Database=syrx;Username=syrx_user;Password=YourStrong!Passw0rd;Include Error Detail=true;" -ForegroundColor White
            Write-Host ""
            Write-Host "Waiting for database initialization..." -ForegroundColor Yellow
            
            # Wait for health check
            $timeout = 60
            $elapsed = 0
            do {
                Start-Sleep 2
                $elapsed += 2
                $status = docker inspect --format='{{.State.Health.Status}}' syrx-postgres-tests 2>$null
                Write-Host "." -NoNewline -ForegroundColor Yellow
                
                if ($elapsed -ge $timeout) {
                    Write-Host ""
                    Write-Host "Timeout waiting for container to become healthy." -ForegroundColor Red
                    Write-Host "Check logs with: .\build-image.ps1 logs" -ForegroundColor Yellow
                    break
                }
            } while ($status -ne "healthy")
            
            if ($status -eq "healthy") {
                Write-Host ""
                Write-Host "Database is ready for connections!" -ForegroundColor Green
            }
        } else {
            Write-Host "Failed to start container!" -ForegroundColor Red
            exit 1
        }
    }
    
    "down" {
        Write-Host "Stopping Syrx PostgreSQL test container..." -ForegroundColor Yellow
        if ($RemoveVolumes) {
            docker-compose down -v
            Write-Host "Container stopped and volumes removed!" -ForegroundColor Green
        } else {
            docker-compose down
            Write-Host "Container stopped!" -ForegroundColor Green
        }
    }
    
    "restart" {
        Write-Host "Restarting Syrx PostgreSQL test container..." -ForegroundColor Yellow
        docker-compose restart
        Write-Host "Container restarted!" -ForegroundColor Green
    }
    
    "logs" {
        Write-Host "Showing container logs..." -ForegroundColor Yellow
        if ($Follow) {
            docker-compose logs -f postgres
        } else {
            docker-compose logs postgres
        }
    }
    
    "status" {
        Write-Host "Container status:" -ForegroundColor Yellow
        docker-compose ps
        Write-Host ""
        
        $containerId = docker ps -q -f name=syrx-postgres-tests
        if ($containerId) {
            Write-Host "Health status:" -ForegroundColor Yellow
            $health = docker inspect --format='{{.State.Health.Status}}' syrx-postgres-tests
            $state = docker inspect --format='{{.State.Status}}' syrx-postgres-tests
            Write-Host "  State: $state" -ForegroundColor White
            Write-Host "  Health: $health" -ForegroundColor White
        } else {
            Write-Host "Container is not running." -ForegroundColor Red
        }
    }
    
    "clean" {
        Write-Host "Cleaning up all Syrx PostgreSQL test resources..." -ForegroundColor Yellow
        docker-compose down -v --remove-orphans
        
        # Also remove the custom image
        docker rmi docker-syrx-postgres-test:latest -f 2>$null
        
        Write-Host "Cleanup completed!" -ForegroundColor Green
    }
    
    "test" {
        Write-Host "Running integration tests..." -ForegroundColor Yellow
        
        # Check if container is running
        $containerId = docker ps -q -f name=syrx-postgres-tests
        if (-not $containerId) {
            Write-Host "PostgreSQL container is not running. Starting it first..." -ForegroundColor Yellow
            & $MyInvocation.MyCommand.Path -Action up
        }
        
        # Navigate to test project directory
        $testProjectDir = Split-Path -Parent $ScriptDir
        Set-Location $testProjectDir
        
        Write-Host "Running Syrx PostgreSQL integration tests..." -ForegroundColor Cyan
        dotnet test --verbosity normal
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Integration tests completed successfully!" -ForegroundColor Green
        } else {
            Write-Host "Integration tests failed!" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host ""
Write-Host "Available commands:" -ForegroundColor Cyan
Write-Host "  build    - Build the custom Docker image for TestContainers (default)" -ForegroundColor White
Write-Host "  up       - Start the container via docker-compose" -ForegroundColor White
Write-Host "  down     - Stop the container" -ForegroundColor White
Write-Host "  restart  - Restart the container" -ForegroundColor White
Write-Host "  logs     - Show container logs (use -Follow for live logs)" -ForegroundColor White
Write-Host "  status   - Show container status" -ForegroundColor White
Write-Host "  clean    - Remove all containers, volumes, and images" -ForegroundColor White
Write-Host "  test     - Run integration tests" -ForegroundColor White
Write-Host ""
Write-Host "Examples:" -ForegroundColor Cyan
Write-Host "  .\build-image.ps1 build    # Build custom image for TestContainers" -ForegroundColor White
Write-Host "  .\build-image.ps1 up       # Start via docker-compose" -ForegroundColor White
Write-Host "  .\build-image.ps1 test     # Run integration tests" -ForegroundColor White
Write-Host "  .\build-image.ps1 logs -Follow" -ForegroundColor White