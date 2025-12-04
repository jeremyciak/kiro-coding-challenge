# User Registration API Deployment

## API Endpoint
**Base URL:** https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod/

## Available Endpoints

### User Management

#### POST /users
Create a new user
- Status: 201 Created
- Body: `{"userId": "string", "name": "string"}`
- Returns: User object
- Validation: userId and name cannot be empty or whitespace-only

### Event Management

#### POST /events
Create a new event
- Status: 201 Created
- Body: `{"eventId": "string", "name": "string", "capacity": integer, "hasWaitlist": boolean}`
- Returns: Event object with empty registered and waitlist arrays
- Validation: capacity must be greater than zero

### Registration Management

#### POST /events/{eventId}/registrations
#### POST /events/{eventId}/register (alias)
Register a user for an event
- Status: 200 OK / 201 Created
- Body: `{"userId": "string"}`
- Returns: Registration confirmation with status ("registered" or "waitlisted")
- Behavior:
  - Adds user to registered list if capacity available
  - Adds user to waitlist if event is full and has waitlist enabled
  - Rejects if event is full and has no waitlist
  - Rejects duplicate registrations

#### DELETE /events/{eventId}/registrations/{userId}
#### DELETE /events/{eventId}/register/{userId} (alias)
Unregister a user from an event
- Status: 200 OK / 204 No Content
- Returns: Unregistration confirmation
- Behavior:
  - Removes user from registered list and increases capacity
  - Promotes first waitlisted user if waitlist is not empty
  - Removes user from waitlist without affecting capacity

#### GET /events/{eventId}/registrations
Get all registrations for an event
- Status: 200 OK
- Returns: `{"registered": ["userId1", ...], "waitlist": ["userId2", ...], "capacity": int, "availableSpots": int}`
- Behavior:
  - Returns list of registered user IDs
  - Returns list of waitlisted user IDs
  - Shows capacity and available spots

#### GET /users/{userId}/registrations
#### GET /users/{userId}/events (alias)
Get all events a user is registered for
- Status: 200 OK
- Returns: `{"events": [Event, ...]}`
- Behavior:
  - Returns only events where user is in registered list
  - Excludes events where user is only on waitlist
  - Returns empty array if user has no registrations

## Data Schemas

### User Schema
```json
{
  "userId": "string",
  "name": "string"
}
```

### Event Schema

**Flexible Schema** - Supports both formats:

```json
{
  "eventId": "string",
  "title": "string (optional, maps to name)",
  "name": "string (optional)",
  "description": "string (optional)",
  "date": "string (optional, YYYY-MM-DD)",
  "location": "string (optional)",
  "capacity": "integer (> 0)",
  "organizer": "string (optional)",
  "status": "string (optional)",
  "waitlistEnabled": "boolean (optional, maps to hasWaitlist)",
  "hasWaitlist": "boolean (optional)",
  "registered": ["userId1", "userId2"],
  "waitlist": ["userId3", "userId4"]
}
```

**Note:** The API accepts both `title`/`waitlistEnabled` (web app format) and `name`/`hasWaitlist` (original format)

## Features
- CORS enabled for web access
- Input validation with detailed error messages
- Capacity enforcement with optional waitlist support
- Automatic waitlist promotion on unregistration
- In-memory storage (suitable for MVP/testing)
- Serverless architecture (API Gateway + Lambda)

## Error Responses
- 400: Validation errors (whitespace, invalid capacity, duplicates)
- 404: Non-existent user/event
- 409: Business logic errors (full event, invalid unregistration)

## Testing
Run `.\test_registration_workflow.ps1` to validate the complete registration workflow.
