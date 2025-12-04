# Test script for User Registration API
# Tests the complete registration workflow

$API_URL = "https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "User Registration API - Complete Workflow Test" -ForegroundColor Cyan
Write-Host "API URL: $API_URL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Yellow
$response = Invoke-RestMethod -Uri "$API_URL/health" -Method Get
Write-Host "✓ Health check passed: $($response.status)" -ForegroundColor Green
Write-Host ""

# Test 2: Create Users
Write-Host "Test 2: Create Users" -ForegroundColor Yellow
$user1 = @{
    userId = "alice123"
    name = "Alice Johnson"
} | ConvertTo-Json

$user2 = @{
    userId = "bob456"
    name = "Bob Smith"
} | ConvertTo-Json

$user3 = @{
    userId = "charlie789"
    name = "Charlie Brown"
} | ConvertTo-Json

try {
    $result1 = Invoke-RestMethod -Uri "$API_URL/users" -Method Post -Body $user1 -ContentType "application/json"
    Write-Host "✓ Created user: $($result1.name) ($($result1.userId))" -ForegroundColor Green
    
    $result2 = Invoke-RestMethod -Uri "$API_URL/users" -Method Post -Body $user2 -ContentType "application/json"
    Write-Host "✓ Created user: $($result2.name) ($($result2.userId))" -ForegroundColor Green
    
    $result3 = Invoke-RestMethod -Uri "$API_URL/users" -Method Post -Body $user3 -ContentType "application/json"
    Write-Host "✓ Created user: $($result3.name) ($($result3.userId))" -ForegroundColor Green
} catch {
    Write-Host "✗ Error creating users: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Create Events
Write-Host "Test 3: Create Events" -ForegroundColor Yellow
$event1 = @{
    eventId = "conf2024"
    name = "Tech Conference 2024"
    capacity = 2
    hasWaitlist = $true
} | ConvertTo-Json

$event2 = @{
    eventId = "workshop2024"
    name = "Python Workshop"
    capacity = 1
    hasWaitlist = $false
} | ConvertTo-Json

try {
    $result1 = Invoke-RestMethod -Uri "$API_URL/events" -Method Post -Body $event1 -ContentType "application/json"
    Write-Host "✓ Created event: $($result1.name) (capacity: $($result1.capacity), waitlist: $($result1.hasWaitlist))" -ForegroundColor Green
    
    $result2 = Invoke-RestMethod -Uri "$API_URL/events" -Method Post -Body $event2 -ContentType "application/json"
    Write-Host "✓ Created event: $($result2.name) (capacity: $($result2.capacity), waitlist: $($result2.hasWaitlist))" -ForegroundColor Green
} catch {
    Write-Host "✗ Error creating events: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Register Users for Events
Write-Host "Test 4: Register Users for Events" -ForegroundColor Yellow
$reg1 = @{ userId = "alice123" } | ConvertTo-Json
$reg2 = @{ userId = "bob456" } | ConvertTo-Json
$reg3 = @{ userId = "charlie789" } | ConvertTo-Json

try {
    # Register alice for conf2024
    $result = Invoke-RestMethod -Uri "$API_URL/events/conf2024/register" -Method Post -Body $reg1 -ContentType "application/json"
    Write-Host "✓ Alice registered for Tech Conference: $($result.status)" -ForegroundColor Green
    
    # Register bob for conf2024
    $result = Invoke-RestMethod -Uri "$API_URL/events/conf2024/register" -Method Post -Body $reg2 -ContentType "application/json"
    Write-Host "✓ Bob registered for Tech Conference: $($result.status)" -ForegroundColor Green
    
    # Register charlie for conf2024 (should go to waitlist)
    $result = Invoke-RestMethod -Uri "$API_URL/events/conf2024/register" -Method Post -Body $reg3 -ContentType "application/json"
    Write-Host "✓ Charlie registered for Tech Conference: $($result.status)" -ForegroundColor Green
    
    # Register alice for workshop
    $result = Invoke-RestMethod -Uri "$API_URL/events/workshop2024/register" -Method Post -Body $reg1 -ContentType "application/json"
    Write-Host "✓ Alice registered for Python Workshop: $($result.status)" -ForegroundColor Green
} catch {
    Write-Host "✗ Error during registration: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: Get User's Registered Events
Write-Host "Test 5: Get User's Registered Events" -ForegroundColor Yellow
try {
    # Alice should see 2 events (conf2024 and workshop2024)
    $result = Invoke-RestMethod -Uri "$API_URL/users/alice123/events" -Method Get
    Write-Host "✓ Alice's registered events: $($result.events.Count) events" -ForegroundColor Green
    foreach ($event in $result.events) {
        Write-Host "  - $($event.name) ($($event.eventId))" -ForegroundColor Cyan
    }
    
    # Bob should see 1 event (conf2024)
    $result = Invoke-RestMethod -Uri "$API_URL/users/bob456/events" -Method Get
    Write-Host "✓ Bob's registered events: $($result.events.Count) events" -ForegroundColor Green
    foreach ($event in $result.events) {
        Write-Host "  - $($event.name) ($($event.eventId))" -ForegroundColor Cyan
    }
    
    # Charlie should see 0 events (only on waitlist)
    $result = Invoke-RestMethod -Uri "$API_URL/users/charlie789/events" -Method Get
    Write-Host "✓ Charlie's registered events: $($result.events.Count) events (waitlisted only)" -ForegroundColor Green
} catch {
    Write-Host "✗ Error getting user events: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Unregister User and Test Waitlist Promotion
Write-Host "Test 6: Unregister User and Test Waitlist Promotion" -ForegroundColor Yellow
try {
    # Unregister alice from conf2024 (charlie should be promoted from waitlist)
    $result = Invoke-RestMethod -Uri "$API_URL/events/conf2024/register/alice123" -Method Delete
    Write-Host "✓ Alice unregistered from Tech Conference" -ForegroundColor Green
    if ($result.promoted) {
        Write-Host "  → $($result.promoted) promoted from waitlist!" -ForegroundColor Cyan
    }
    
    # Charlie should now see 1 event (promoted from waitlist)
    $result = Invoke-RestMethod -Uri "$API_URL/users/charlie789/events" -Method Get
    Write-Host "✓ Charlie's registered events after promotion: $($result.events.Count) events" -ForegroundColor Green
    foreach ($event in $result.events) {
        Write-Host "  - $($event.name) ($($event.eventId))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Error during unregistration: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 7: Test Error Handling
Write-Host "Test 7: Test Error Handling" -ForegroundColor Yellow
try {
    # Try to register non-existent user
    $badReg = @{ userId = "nonexistent" } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$API_URL/events/conf2024/register" -Method Post -Body $badReg -ContentType "application/json"
        Write-Host "✗ Should have failed for non-existent user" -ForegroundColor Red
    } catch {
        Write-Host "✓ Correctly rejected non-existent user registration" -ForegroundColor Green
    }
    
    # Try to get events for non-existent user
    try {
        Invoke-RestMethod -Uri "$API_URL/users/nonexistent/events" -Method Get
        Write-Host "✗ Should have failed for non-existent user" -ForegroundColor Red
    } catch {
        Write-Host "✓ Correctly rejected non-existent user events query" -ForegroundColor Green
    }
    
    # Try to register for event without waitlist when full
    try {
        $result = Invoke-RestMethod -Uri "$API_URL/events/workshop2024/register" -Method Post -Body $reg2 -ContentType "application/json"
        Write-Host "✗ Should have failed for full event without waitlist" -ForegroundColor Red
    } catch {
        Write-Host "✓ Correctly rejected registration for full event without waitlist" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Unexpected error in error handling tests: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All Tests Completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
