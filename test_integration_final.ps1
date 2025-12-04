# Final Integration Test - User Registration System
# Demonstrates complete workflow with all endpoints

$API_URL = "https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  User Registration System - Final Integration Test        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [scriptblock]$Test
    )
    
    Write-Host "→ $Name" -ForegroundColor Yellow
    try {
        & $Test
        Write-Host "  ✓ PASSED`n" -ForegroundColor Green
        $script:testsPassed++
    } catch {
        Write-Host "  ✗ FAILED: $($_.Exception.Message)`n" -ForegroundColor Red
        $script:testsFailed++
    }
}

# Scenario: Tech Conference with Limited Capacity
Write-Host "SCENARIO: Tech Conference with Limited Capacity and Waitlist`n" -ForegroundColor Magenta

Test-Endpoint "1. Create three users (Alice, Bob, Charlie)" {
    $users = @(
        @{ userId = "alice_final"; name = "Alice Williams" },
        @{ userId = "bob_final"; name = "Bob Davis" },
        @{ userId = "charlie_final"; name = "Charlie Miller" }
    )
    
    foreach ($user in $users) {
        $body = $user | ConvertTo-Json
        $result = Invoke-RestMethod -Uri "$API_URL/users" -Method Post -Body $body -ContentType "application/json"
        if ($result.userId -ne $user.userId) {
            throw "User creation failed for $($user.userId)"
        }
    }
    Write-Host "  Created: Alice, Bob, Charlie" -ForegroundColor Cyan
}

Test-Endpoint "2. Create event with capacity of 2 and waitlist enabled" {
    $event = @{
        eventId = "techconf_final"
        name = "Tech Conference 2024"
        capacity = 2
        hasWaitlist = $true
    } | ConvertTo-Json
    
    $result = Invoke-RestMethod -Uri "$API_URL/events" -Method Post -Body $event -ContentType "application/json"
    if ($result.capacity -ne 2 -or $result.hasWaitlist -ne $true) {
        throw "Event creation failed"
    }
    Write-Host "  Event: Tech Conference 2024 (capacity: 2, waitlist: enabled)" -ForegroundColor Cyan
}

Test-Endpoint "3. Register Alice (should succeed - spot 1/2)" {
    $reg = @{ userId = "alice_final" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$API_URL/events/techconf_final/register" -Method Post -Body $reg -ContentType "application/json"
    if ($result.status -ne "registered") {
        throw "Alice should be registered, got: $($result.status)"
    }
    Write-Host "  Alice: REGISTERED (1/2 spots filled)" -ForegroundColor Cyan
}

Test-Endpoint "4. Register Bob (should succeed - spot 2/2)" {
    $reg = @{ userId = "bob_final" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$API_URL/events/techconf_final/register" -Method Post -Body $reg -ContentType "application/json"
    if ($result.status -ne "registered") {
        throw "Bob should be registered, got: $($result.status)"
    }
    Write-Host "  Bob: REGISTERED (2/2 spots filled - FULL)" -ForegroundColor Cyan
}

Test-Endpoint "5. Register Charlie (should go to waitlist)" {
    $reg = @{ userId = "charlie_final" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$API_URL/events/techconf_final/register" -Method Post -Body $reg -ContentType "application/json"
    if ($result.status -ne "waitlisted") {
        throw "Charlie should be waitlisted, got: $($result.status)"
    }
    Write-Host "  Charlie: WAITLISTED (event full)" -ForegroundColor Cyan
}

Test-Endpoint "6. Verify Alice sees 1 registered event" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/alice_final/events" -Method Get
    if ($result.events.Count -ne 1) {
        throw "Alice should see 1 event, got: $($result.events.Count)"
    }
    Write-Host "  Alice's events: $($result.events.Count) (Tech Conference 2024)" -ForegroundColor Cyan
}

Test-Endpoint "7. Verify Bob sees 1 registered event" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/bob_final/events" -Method Get
    if ($result.events.Count -ne 1) {
        throw "Bob should see 1 event, got: $($result.events.Count)"
    }
    Write-Host "  Bob's events: $($result.events.Count) (Tech Conference 2024)" -ForegroundColor Cyan
}

Test-Endpoint "8. Verify Charlie sees 0 registered events (waitlisted only)" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/charlie_final/events" -Method Get
    if ($result.events.Count -ne 0) {
        throw "Charlie should see 0 events (waitlisted), got: $($result.events.Count)"
    }
    Write-Host "  Charlie's events: $($result.events.Count) (on waitlist, not registered)" -ForegroundColor Cyan
}

Test-Endpoint "9. Alice unregisters (Charlie should be promoted)" {
    $result = Invoke-RestMethod -Uri "$API_URL/events/techconf_final/register/alice_final" -Method Delete
    if (-not $result.promoted) {
        throw "Expected promotion from waitlist"
    }
    if ($result.promoted -ne "charlie_final") {
        throw "Expected Charlie to be promoted, got: $($result.promoted)"
    }
    Write-Host "  Alice: UNREGISTERED" -ForegroundColor Cyan
    Write-Host "  Charlie: PROMOTED from waitlist → REGISTERED" -ForegroundColor Cyan
}

Test-Endpoint "10. Verify Charlie now sees 1 registered event" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/charlie_final/events" -Method Get
    if ($result.events.Count -ne 1) {
        throw "Charlie should see 1 event after promotion, got: $($result.events.Count)"
    }
    Write-Host "  Charlie's events: $($result.events.Count) (promoted to registered)" -ForegroundColor Cyan
}

Test-Endpoint "11. Verify Alice now sees 0 registered events" {
    $result = Invoke-RestMethod -Uri "$API_URL/users/alice_final/events" -Method Get
    if ($result.events.Count -ne 0) {
        throw "Alice should see 0 events after unregistering, got: $($result.events.Count)"
    }
    Write-Host "  Alice's events: $($result.events.Count) (unregistered)" -ForegroundColor Cyan
}

# Error Handling Tests
Write-Host "`nERROR HANDLING TESTS`n" -ForegroundColor Magenta

Test-Endpoint "12. Reject registration for non-existent user" {
    $reg = @{ userId = "nonexistent" } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$API_URL/events/techconf_final/register" -Method Post -Body $reg -ContentType "application/json"
        throw "Should have rejected non-existent user"
    } catch {
        if ($_.Exception.Response.StatusCode -ne 404) {
            throw "Expected 404, got: $($_.Exception.Response.StatusCode)"
        }
    }
    Write-Host "  Correctly rejected with 404" -ForegroundColor Cyan
}

Test-Endpoint "13. Reject duplicate user registration" {
    $reg = @{ userId = "bob_final" } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$API_URL/events/techconf_final/register" -Method Post -Body $reg -ContentType "application/json"
        throw "Should have rejected duplicate registration"
    } catch {
        if ($_.Exception.Response.StatusCode -ne 400) {
            throw "Expected 400, got: $($_.Exception.Response.StatusCode)"
        }
    }
    Write-Host "  Correctly rejected with 400" -ForegroundColor Cyan
}

Test-Endpoint "14. Reject events query for non-existent user" {
    try {
        Invoke-RestMethod -Uri "$API_URL/users/nonexistent/events" -Method Get
        throw "Should have rejected non-existent user"
    } catch {
        if ($_.Exception.Response.StatusCode -ne 404) {
            throw "Expected 404, got: $($_.Exception.Response.StatusCode)"
        }
    }
    Write-Host "  Correctly rejected with 404" -ForegroundColor Cyan
}

Test-Endpoint "15. Reject event creation with invalid capacity" {
    $event = @{
        eventId = "invalid_event"
        name = "Invalid Event"
        capacity = 0
        hasWaitlist = $false
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri "$API_URL/events" -Method Post -Body $event -ContentType "application/json"
        throw "Should have rejected capacity <= 0"
    } catch {
        if ($_.Exception.Response.StatusCode -ne 400) {
            throw "Expected 400, got: $($_.Exception.Response.StatusCode)"
        }
    }
    Write-Host "  Correctly rejected with 400" -ForegroundColor Cyan
}

# Summary
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      TEST SUMMARY                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })

if ($testsFailed -eq 0) {
    Write-Host "`n✓ ALL TESTS PASSED - System is working correctly!`n" -ForegroundColor Green
} else {
    Write-Host "`n✗ SOME TESTS FAILED - Please review the errors above`n" -ForegroundColor Red
    exit 1
}
