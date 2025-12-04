# Final Verification Test - All Endpoint Formats
$API_URL = "https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Final Verification - All Endpoint Formats         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$passed = 0
$failed = 0

function Test-Endpoint {
    param([string]$Name, [scriptblock]$Test)
    Write-Host "→ $Name" -ForegroundColor Yellow
    try {
        & $Test
        Write-Host "  ✓ PASSED`n" -ForegroundColor Green
        $script:passed++
    } catch {
        Write-Host "  ✗ FAILED: $($_.Exception.Message)`n" -ForegroundColor Red
        $script:failed++
    }
}

Write-Host "SCENARIO 1: Web Application Format (with /registrations)" -ForegroundColor Magenta
Write-Host ""

Test-Endpoint "1. Create event with web app schema" {
    $event = @{
        eventId = "webapp-event"
        title = "Web App Event"
        description = "Testing web app format"
        date = "2024-12-25"
        location = "Online"
        capacity = 2
        organizer = "Test Org"
        status = "active"
        waitlistEnabled = $true
    } | ConvertTo-Json
    
    $result = Invoke-RestMethod -Uri "$API_URL/events" -Method Post -Body $event -ContentType "application/json"
    if ($result.eventId -ne "webapp-event" -or $result.hasWaitlist -ne $true) {
        throw "Event creation failed or schema mapping incorrect"
    }
}

Test-Endpoint "2. Create users" {
    $users = @("webapp-user-1", "webapp-user-2", "webapp-user-3")
    foreach ($userId in $users) {
        $user = @{ userId = $userId; name = "User $userId" } | ConvertTo-Json
        $result = Invoke-RestMethod -Uri "$API_URL/users" -Method Post -Body $user -ContentType "application/json"
        if ($result.userId -ne $userId) {
            throw "User creation failed for $userId"
        }
    }
}

Test-Endpoint "3. Register via /registrations endpoint" {
    $reg1 = @{ userId = "webapp-user-1" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$API_URL/events/webapp-event/registrations" -Method Post -Body $reg1 -ContentType "application/json"
    if ($result.status -ne "registered") {
        throw "Registration failed"
    }
}

Test-Endpoint "4. Get registrations via /registrations endpoint" {
    $result = Invoke-RestMethod -Uri "$API_URL/events/webapp-event/registrations" -Method Get
    if ($result.registered.Count -ne 1 -or $result.registered[0] -ne "webapp-user-1") {
        throw "Get registrations failed"
    }
}

Test-Endpoint "5. Get user registrations via /registrations endpoint" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/webapp-user-1/registrations" -Method Get
    if ($result.events.Count -ne 1) {
        throw "Get user registrations failed"
    }
}

Test-Endpoint "6. Unregister via /registrations endpoint" {
    $result = Invoke-RestMethod -Uri "$API_URL/events/webapp-event/registrations/webapp-user-1" -Method Delete
    if (-not $result.message) {
        throw "Unregistration failed"
    }
}

Write-Host "`nSCENARIO 2: Original Format (with /register)" -ForegroundColor Magenta
Write-Host ""

Test-Endpoint "7. Create event with original schema" {
    $event = @{
        eventId = "original-event"
        name = "Original Event"
        capacity = 2
        hasWaitlist = $true
    } | ConvertTo-Json
    
    $result = Invoke-RestMethod -Uri "$API_URL/events" -Method Post -Body $event -ContentType "application/json"
    if ($result.eventId -ne "original-event") {
        throw "Event creation failed"
    }
}

Test-Endpoint "8. Register via /register endpoint" {
    $reg = @{ userId = "webapp-user-2" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$API_URL/events/original-event/register" -Method Post -Body $reg -ContentType "application/json"
    if ($result.status -ne "registered") {
        throw "Registration failed"
    }
}

Test-Endpoint "9. Get user events via /events endpoint" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/webapp-user-2/events" -Method Get
    if ($result.events.Count -ne 1) {
        throw "Get user events failed"
    }
}

Test-Endpoint "10. Unregister via /register endpoint" {
    $result = Invoke-RestMethod -Uri "$API_URL/events/original-event/register/webapp-user-2" -Method Delete
    if (-not $result.message) {
        throw "Unregistration failed"
    }
}

Write-Host "`nSCENARIO 3: Complete Workflow with Waitlist" -ForegroundColor Magenta
Write-Host ""

Test-Endpoint "11. Fill event to capacity" {
    $reg1 = @{ userId = "webapp-user-1" } | ConvertTo-Json
    $reg2 = @{ userId = "webapp-user-2" } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$API_URL/events/webapp-event/registrations" -Method Post -Body $reg1 -ContentType "application/json" | Out-Null
    Invoke-RestMethod -Uri "$API_URL/events/webapp-event/registrations" -Method Post -Body $reg2 -ContentType "application/json" | Out-Null
}

Test-Endpoint "12. Add user to waitlist" {
    $reg3 = @{ userId = "webapp-user-3" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$API_URL/events/webapp-event/registrations" -Method Post -Body $reg3 -ContentType "application/json"
    if ($result.status -ne "waitlisted") {
        throw "User should be waitlisted"
    }
}

Test-Endpoint "13. Verify waitlisted user not in registrations" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/webapp-user-3/registrations" -Method Get
    if ($result.events.Count -ne 0) {
        throw "Waitlisted user should not see registered events"
    }
}

Test-Endpoint "14. Unregister and promote from waitlist" {
    $result = Invoke-RestMethod -Uri "$API_URL/events/webapp-event/registrations/webapp-user-1" -Method Delete
    if ($result.promoted -ne "webapp-user-3") {
        throw "Waitlist promotion failed"
    }
}

Test-Endpoint "15. Verify promoted user now in registrations" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/webapp-user-3/registrations" -Method Get
    if ($result.events.Count -ne 1) {
        throw "Promoted user should see registered event"
    }
}

# Summary
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      FINAL SUMMARY                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Tests Passed: $passed / $($passed + $failed)" -ForegroundColor Green
Write-Host "Tests Failed: $failed / $($passed + $failed)" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($failed -eq 0) {
    Write-Host "`n✓ ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "  • Web application format (/registrations) works ✓" -ForegroundColor Cyan
    Write-Host "  • Original format (/register) works ✓" -ForegroundColor Cyan
    Write-Host "  • Complete workflow with waitlist works ✓" -ForegroundColor Cyan
    Write-Host "  • Both endpoint formats are fully compatible ✓`n" -ForegroundColor Cyan
} else {
    Write-Host "`n✗ SOME TESTS FAILED`n" -ForegroundColor Red
    exit 1
}
