# Web Application Compatibility Guide

## Overview

The User Registration API has been updated to support **both** the original endpoint format and the web application's expected endpoint format. Both formats work simultaneously and are fully compatible.

## API Base URL
```
https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod/
```

## Supported Endpoint Formats

### 1. Web Application Format (Primary)

These endpoints match the web application's expectations:

#### Create Event
```http
POST /events
Content-Type: application/json

{
  "eventId": "reg-test-event-789",
  "title": "Registration Test Event",
  "description": "Event for testing user registration functionality",
  "date": "2024-12-20",
  "location": "Test Location",
  "capacity": 2,
  "organizer": "Test Organizer",
  "status": "active",
  "waitlistEnabled": true
}
```
**Response:** 200 OK or 201 Created

#### Create User
```http
POST /users
Content-Type: application/json

{
  "userId": "test-user-1",
  "name": "Test User 1"
}
```
**Response:** 200 OK or 201 Created

#### Register User for Event
```http
POST /events/{eventId}/registrations
Content-Type: application/json

{
  "userId": "test-user-1"
}
```
**Response:** 200 OK or 201 Created
```json
{
  "message": "User 'test-user-1' successfully registered for event 'reg-test-event-789'",
  "status": "registered"
}
```

#### Get Event Registrations
```http
GET /events/{eventId}/registrations
```
**Response:** 200 OK
```json
{
  "registered": ["test-user-1", "test-user-2"],
  "waitlist": ["test-user-3"],
  "capacity": 2,
  "availableSpots": 0
}
```

#### Get User Registrations
```http
GET /users/{userId}/registrations
```
**Response:** 200 OK
```json
{
  "events": [
    {
      "eventId": "reg-test-event-789",
      "title": "Registration Test Event",
      "name": "Registration Test Event",
      "capacity": 2,
      "hasWaitlist": true,
      "registered": ["test-user-1", "test-user-2"],
      "waitlist": ["test-user-3"]
    }
  ]
}
```

#### Unregister User from Event
```http
DELETE /events/{eventId}/registrations/{userId}
```
**Response:** 200 OK or 204 No Content
```json
{
  "message": "User 'test-user-1' unregistered from event 'reg-test-event-789'. User 'test-user-3' promoted from waitlist",
  "promoted": "test-user-3"
}
```

---

### 2. Original Format (Also Supported)

These endpoints use the original naming convention and are still fully functional:

- `POST /events/{eventId}/register` → Register user
- `DELETE /events/{eventId}/register/{userId}` → Unregister user
- `GET /users/{userId}/events` → Get user's events

---

## Schema Flexibility

The API accepts **both** schema formats for events:

### Web Application Schema
```json
{
  "eventId": "string",
  "title": "string",
  "description": "string",
  "date": "string",
  "location": "string",
  "capacity": integer,
  "organizer": "string",
  "status": "string",
  "waitlistEnabled": boolean
}
```

### Original Schema
```json
{
  "eventId": "string",
  "name": "string",
  "capacity": integer,
  "hasWaitlist": boolean
}
```

**Automatic Mapping:**
- `title` → `name` (internally)
- `waitlistEnabled` → `hasWaitlist` (internally)

---

## Complete Test Sequence

Here's the exact sequence the web application will use:

```bash
# 1. Create Event
POST /events
{
  "date": "2024-12-20",
  "eventId": "reg-test-event-789",
  "waitlistEnabled": true,
  "organizer": "Test Organizer",
  "description": "Event for testing user registration functionality",
  "location": "Test Location",
  "title": "Registration Test Event",
  "capacity": 2,
  "status": "active"
}
→ Expected: 200 or 201 ✓

# 2-4. Create Users
POST /users {"name": "Test User 1", "userId": "test-user-1"}
POST /users {"name": "Test User 2", "userId": "test-user-2"}
POST /users {"name": "Test User 3", "userId": "test-user-3"}
→ Expected: 200 or 201 ✓

# 5-7. Register Users
POST /events/reg-test-event-789/registrations {"userId": "test-user-1"}
POST /events/reg-test-event-789/registrations {"userId": "test-user-2"}
POST /events/reg-test-event-789/registrations {"userId": "test-user-3"}
→ Expected: 200 or 201 ✓
→ User 3 goes to waitlist ✓

# 8. Get Event Registrations
GET /events/reg-test-event-789/registrations
→ Expected: 200 ✓
→ Returns: registered: [user-1, user-2], waitlist: [user-3] ✓

# 9. Get User Registrations
GET /users/test-user-1/registrations
→ Expected: 200 ✓
→ Returns: events array with 1 event ✓

# 10. Unregister User
DELETE /events/reg-test-event-789/registrations/test-user-1
→ Expected: 200 or 204 ✓
→ User 3 promoted from waitlist ✓
```

---

## Key Features Verified

✅ **Dual Endpoint Support**
- Both `/registrations` and `/register` endpoints work
- Both `/registrations` and `/events` endpoints work for user queries

✅ **Schema Flexibility**
- Accepts `title` or `name` for event names
- Accepts `waitlistEnabled` or `hasWaitlist` for waitlist configuration
- Supports optional fields (description, date, location, organizer, status)

✅ **Complete Functionality**
- User creation with validation
- Event creation with capacity constraints
- Registration with capacity tracking
- Waitlist management
- Automatic waitlist promotion
- Event and user queries

✅ **Error Handling**
- 400: Validation errors (whitespace, duplicates, invalid capacity)
- 404: Non-existent users or events
- 409: Business logic errors (full events, invalid operations)

---

## Testing

### Run Web App Compatibility Test
```powershell
.\test_web_app_endpoints.ps1
```

### Run Complete Verification
```powershell
.\test_final_verification.ps1
```

### Run Original Workflow Test
```powershell
.\test_registration_workflow.ps1
```

---

## Status

✅ **READY FOR WEB APPLICATION**

All expected endpoints are implemented and tested:
- ✅ POST /events (with web app schema)
- ✅ POST /users
- ✅ POST /events/{eventId}/registrations
- ✅ GET /events/{eventId}/registrations
- ✅ GET /users/{userId}/registrations
- ✅ DELETE /events/{eventId}/registrations/{userId}

All tests pass with expected status codes (200, 201, 204).

---

## Support

For issues or questions:
1. Check `DEPLOYMENT.md` for complete API documentation
2. Review `WORKFLOW_DEMO.md` for usage examples
3. Run test scripts to validate functionality
4. Check CloudWatch logs for detailed error information

**Last Updated:** December 3, 2025
**API Version:** 2.0 (Dual Format Support)
