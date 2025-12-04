# Events API Deployment

## API Endpoint
**Base URL:** https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod/

## Available Endpoints

### GET /events
List all events
- Status: 200 OK
- Query Parameters: `status` (optional) - filter by event status

### POST /events
Create a new event
- Status: 201 Created
- Returns: Event object with eventId

### GET /events/{eventId}
Get a specific event
- Status: 200 OK

### PUT /events/{eventId}
Update an event
- Status: 200 OK
- Supports partial updates

### DELETE /events/{eventId}
Delete an event
- Status: 200 OK

## Event Schema
```json
{
  "eventId": "string (optional on create)",
  "title": "string (1-200 chars)",
  "description": "string (1-1000 chars)",
  "date": "string (YYYY-MM-DD format)",
  "location": "string (1-200 chars)",
  "capacity": "integer (> 0)",
  "organizer": "string (1-200 chars)",
  "status": "string (active|inactive|cancelled|completed)"
}
```

## Features
- CORS enabled for web access
- Input validation with detailed error messages
- Query parameter support for filtering
- DynamoDB backend for scalable storage
- Serverless architecture (API Gateway + Lambda)

## Testing
Run `.\test_api.ps1` to validate all endpoints.
