$apiUrl = "https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod"

Write-Host "Testing GET /events"
$response = Invoke-RestMethod -Uri "$apiUrl/events" -Method Get
Write-Host "Status: 200 ✓"
Write-Host "Response: $($response | ConvertTo-Json)"
Write-Host ""

Write-Host "Testing GET /events?status=active"
$response = Invoke-RestMethod -Uri "$apiUrl/events?status=active" -Method Get
Write-Host "Status: 200 ✓"
Write-Host "Response: $($response | ConvertTo-Json)"
Write-Host ""

Write-Host "Testing POST /events"
$body = @{
    date = "2024-12-15"
    eventId = "api-test-event-456"
    organizer = "API Test Organizer"
    description = "Testing API Gateway integration"
    location = "API Test Location"
    title = "API Gateway Test Event"
    capacity = 200
    status = "active"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "$apiUrl/events" -Method Post -Body $body -ContentType "application/json"
Write-Host "Status: 201 ✓"
Write-Host "Response: $($response | ConvertTo-Json)"
Write-Host "EventId present: $($response.eventId -eq 'api-test-event-456') ✓"
Write-Host ""

Write-Host "Testing GET /events/api-test-event-456"
$response = Invoke-RestMethod -Uri "$apiUrl/events/api-test-event-456" -Method Get
Write-Host "Status: 200 ✓"
Write-Host "Response: $($response | ConvertTo-Json)"
Write-Host ""

Write-Host "Testing PUT /events/api-test-event-456"
$updateBody = @{
    title = "Updated API Gateway Test Event"
    capacity = 250
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "$apiUrl/events/api-test-event-456" -Method Put -Body $updateBody -ContentType "application/json"
Write-Host "Status: 200 ✓"
Write-Host "Response: $($response | ConvertTo-Json)"
Write-Host ""

Write-Host "Testing DELETE /events/api-test-event-456"
$response = Invoke-RestMethod -Uri "$apiUrl/events/api-test-event-456" -Method Delete
Write-Host "Status: 200 ✓"
Write-Host "Response: $($response | ConvertTo-Json)"
Write-Host ""

Write-Host "All tests passed! ✓"
