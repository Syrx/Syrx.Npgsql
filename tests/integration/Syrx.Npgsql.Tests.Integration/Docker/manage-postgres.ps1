# Syrx PostgreSQL Docker Management Script
# This script helps manage the PostgreSQL Docker container for integration testing

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "clean", "test", "connect")]
    [string]$Action = "start"
)

$ErrorActionPreference = "Stop"

# Configuration
$ComposeFile = "docker-compose.yml"
$ContainerName = "syrx-postgres-tests"
$ServiceName = "postgres"

# Ensure we're in the correct directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "Syrx PostgreSQL Docker Management" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

switch ($Action.ToLower()) {
    "start" {
        Write-Host "Starting PostgreSQL container..." -ForegroundColor Yellow
        docker-compose up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PostgreSQL container started successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Connection Details:" -ForegroundColor Cyan
            Write-Host "  Host: localhost" -ForegroundColor White
            Write-Host "  Port: 5432" -ForegroundColor White
            Write-Host "  Database: syrx" -ForegroundColor White
            Write-Host "  Username: syrx_user" -ForegroundColor White
            Write-Host "  Password: YourStrong!Passw0rd" -ForegroundColor White
            Write-Host ""
            Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
            
            # Wait for health check to pass
            $maxAttempts = 30
            $attempt = 0
            do {
                Start-Sleep -Seconds 2
                $attempt++
                $health = docker inspect --format='{{.State.Health.Status}}' $ContainerName 2>$null
                Write-Host "." -NoNewline -ForegroundColor Yellow
            } while ($health -ne "healthy" -and $attempt -lt $maxAttempts)
            
            Write-Host ""
            if ($health -eq "healthy") {
                Write-Host "Database is ready for connections!" -ForegroundColor Green
            } else {
                Write-Host "Warning: Database health check timeout. Check logs with: .\manage-postgres.ps1 logs" -ForegroundColor Red
            }
        } else {
            Write-Host "Failed to start PostgreSQL container!" -ForegroundColor Red
            exit 1
        }
    }
    
    "stop" {
        Write-Host "Stopping PostgreSQL container..." -ForegroundColor Yellow
        docker-compose stop
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PostgreSQL container stopped successfully!" -ForegroundColor Green
        } else {
            Write-Host "Failed to stop PostgreSQL container!" -ForegroundColor Red
            exit 1
        }
    }
    
    "restart" {
        Write-Host "Restarting PostgreSQL container..." -ForegroundColor Yellow
        docker-compose restart
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PostgreSQL container restarted successfully!" -ForegroundColor Green
        } else {
            Write-Host "Failed to restart PostgreSQL container!" -ForegroundColor Red
            exit 1
        }
    }
    
    "status" {
        Write-Host "PostgreSQL container status:" -ForegroundColor Yellow
        docker-compose ps
        Write-Host ""
        
        $containerId = docker ps -q -f name=$ContainerName
        if ($containerId) {
            Write-Host "Container Health Status:" -ForegroundColor Cyan
            $health = docker inspect --format='{{.State.Health.Status}}' $ContainerName
            $status = docker inspect --format='{{.State.Status}}' $ContainerName
            Write-Host "  Status: $status" -ForegroundColor White
            Write-Host "  Health: $health" -ForegroundColor White
        } else {
            Write-Host "Container is not running." -ForegroundColor Red
        }
    }
    
    "logs" {
        Write-Host "PostgreSQL container logs:" -ForegroundColor Yellow
        docker-compose logs $ServiceName
    }
    
    "clean" {
        Write-Host "Cleaning up PostgreSQL environment..." -ForegroundColor Yellow
        Write-Host "This will remove containers, volumes, and networks." -ForegroundColor Red
        $confirm = Read-Host "Are you sure? (y/N)"
        
        if ($confirm -eq "y" -or $confirm -eq "Y") {
            docker-compose down -v --remove-orphans
            if ($LASTEXITCODE -eq 0) {
                Write-Host "PostgreSQL environment cleaned successfully!" -ForegroundColor Green
            } else {
                Write-Host "Failed to clean PostgreSQL environment!" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "Clean operation cancelled." -ForegroundColor Yellow
        }
    }
    
    "test" {
        Write-Host "Running integration tests..." -ForegroundColor Yellow
        
        # Check if container is running
        $containerId = docker ps -q -f name=$ContainerName
        if (-not $containerId) {
            Write-Host "PostgreSQL container is not running. Starting it first..." -ForegroundColor Yellow
            & $MyInvocation.MyCommand.Path -Action start
        }
        
        # Navigate to test project directory
        $testProjectDir = Split-Path -Parent $ScriptDir
        Set-Location $testProjectDir
        
        Write-Host "Running Syrx PostgreSQL integration tests..." -ForegroundColor Cyan
        dotnet test --verbosity normal --filter "ClassName~NpgsqlDocker"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Integration tests completed successfully!" -ForegroundColor Green
        } else {
            Write-Host "Integration tests failed!" -ForegroundColor Red
            exit 1
        }
    }
    
    "connect" {
        Write-Host "Connecting to PostgreSQL database..." -ForegroundColor Yellow
        
        # Check if container is running
        $containerId = docker ps -q -f name=$ContainerName
        if (-not $containerId) {
            Write-Host "PostgreSQL container is not running. Please start it first with: .\manage-postgres.ps1 start" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Opening psql connection to Syrx database..." -ForegroundColor Cyan
        Write-Host "Use \dt to list tables, \q to quit" -ForegroundColor Yellow
        docker exec -it $ContainerName psql -U syrx_user -d syrx
    }
    
    default {
        Write-Host "Invalid action: $Action" -ForegroundColor Red
        Write-Host ""
        Write-Host "Usage: .\manage-postgres.ps1 -Action <action>" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Available actions:" -ForegroundColor Cyan
        Write-Host "  start    - Start the PostgreSQL container" -ForegroundColor White
        Write-Host "  stop     - Stop the PostgreSQL container" -ForegroundColor White
        Write-Host "  restart  - Restart the PostgreSQL container" -ForegroundColor White
        Write-Host "  status   - Show container status and health" -ForegroundColor White
        Write-Host "  logs     - Show container logs" -ForegroundColor White
        Write-Host "  clean    - Remove containers, volumes, and networks" -ForegroundColor White
        Write-Host "  test     - Run integration tests" -ForegroundColor White
        Write-Host "  connect  - Connect to database with psql" -ForegroundColor White
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\manage-postgres.ps1 start" -ForegroundColor Gray
        Write-Host "  .\manage-postgres.ps1 test" -ForegroundColor Gray
        Write-Host "  .\manage-postgres.ps1 logs" -ForegroundColor Gray
        exit 1
    }
}