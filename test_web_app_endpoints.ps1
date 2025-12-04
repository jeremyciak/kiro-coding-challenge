# Test script matching the web application's expected endpoints
$API_URL = "https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Testing Web Application Expected Endpoints               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

function Test-Request {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [object]$Body,
        [int[]]$ExpectedStatus
    )
    
    Write-Host "→ $Method $Endpoint" -ForegroundColor Yellow
    try {
        $params = @{
            Uri = "$API_URL$Endpoint"
            Method = $Method
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @params
        $statusCode = 200  # Default for successful Invoke-RestMethod
        
        if ($ExpectedStatus -contains $statusCode) {
            Write-Host "  ✓ Status: $statusCode" -ForegroundColor Green
            Write-Host "  Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Cyan
            $script:testsPassed++
        } else {
            Write-Host "  ✗ Unexpected status: $statusCode (expected: $($ExpectedStatus -join ', '))" -ForegroundColor Red
            $script:testsFailed++
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($ExpectedStatus -contains $statusCode) {
            Write-Host "  ✓ Status: $statusCode" -ForegroundColor Green
            $script:testsPassed++
        } else {
            Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
            $script:testsFailed++
        }
    }
    Write-Host ""
}

# Test 1: POST /events
Write-Host "TEST 1: Create Event" -ForegroundColor Magenta
Test-Request -Name "Create Event" -Method "POST" -Endpoint "/events" -ExpectedStatus @(200, 201) -Body @{
    date = "2024-12-20"
    eventId = "reg-test-event-789"
    waitlistEnabled = $true
    organizer = "Test Organizer"
    description = "Event for testing user registration functionality"
    location = "Test Location"
    title = "Registration Test Event"
    capacity = 2
    status = "active"
}

# Test 2-4: POST /users
Write-Host "TEST 2-4: Create Users" -ForegroundColor Magenta
Test-Request -Name "Create User 1" -Method "POST" -Endpoint "/users" -ExpectedStatus @(200, 201) -Body @{
    name = "Test User 1"
    userId = "test-user-1"
}

Test-Request -Name "Create User 2" -Method "POST" -Endpoint "/users" -ExpectedStatus @(200, 201) -Body @{
    name = "Test User 2"
    userId = "test-user-2"
}

Test-Request -Name "Create User 3" -Method "POST" -Endpoint "/users" -ExpectedStatus @(200, 201) -Body @{
    name = "Test User 3"
    userId = "test-user-3"
}

# Test 5-7: POST /events/{eventId}/registrations
Write-Host "TEST 5-7: Register Users for Event" -ForegroundColor Magenta
Test-Request -Name "Register User 1" -Method "POST" -Endpoint "/events/reg-test-event-789/registrations" -ExpectedStatus @(200, 201) -Body @{
    userId = "test-user-1"
}

Test-Request -Name "Register User 2" -Method "POST" -Endpoint "/events/reg-test-event-789/registrations" -ExpectedStatus @(200, 201) -Body @{
    userId = "test-user-2"
}

Test-Request -Name "Register User 3 (waitlist)" -Method "POST" -Endpoint "/events/reg-test-event-789/registrations" -ExpectedStatus @(200, 201) -Body @{
    userId = "test-user-3"
}

# Test 8: GET /events/{eventId}/registrations
Write-Host "TEST 8: Get Event Registrations" -ForegroundColor Magenta
Test-Request -Name "Get Event Registrations" -Method "GET" -Endpoint "/events/reg-test-event-789/registrations" -ExpectedStatus @(200)

# Test 9: GET /users/{userId}/registrations
Write-Host "TEST 9: Get User Registrations" -ForegroundColor Magenta
Test-Request -Name "Get User 1 Registrations" -Method "GET" -Endpoint "/users/test-user-1/registrations" -ExpectedStatus @(200)

# Test 10: DELETE /events/{eventId}/registrations/{userId}
Write-Host "TEST 10: Unregister User" -ForegroundColor Magenta
Test-Request -Name "Unregister User 1" -Method "DELETE" -Endpoint "/events/reg-test-event-789/registrations/test-user-1" -ExpectedStatus @(200, 204)

# Summary
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      TEST SUMMARY                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })

if ($testsFailed -eq 0) {
    Write-Host "`n✓ ALL TESTS PASSED - API matches web application expectations!`n" -ForegroundColor Green
} else {
    Write-Host "`n✗ SOME TESTS FAILED - Please review the errors above`n" -ForegroundColor Red
    exit 1
}
