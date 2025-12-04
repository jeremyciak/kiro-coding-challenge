# Design Document

## Overview

A simple REST API for user registration with capacity-constrained events and optional waitlists. Uses in-memory storage with FastAPI.

## Architecture

Single-file FastAPI application with:
- Pydantic models for data validation
- In-memory dictionaries for storage
- Direct endpoint handlers (no separate service layer for MVP)

## Data Models

```python
class User(BaseModel):
    userId: str
    name: str

class Event(BaseModel):
    eventId: str
    name: str
    capacity: int
    hasWaitlist: bool
    registered: List[str] = []  # user IDs
    waitlist: List[str] = []    # user IDs

# Storage
users: Dict[str, User] = {}
events: Dict[str, Event] = {}
```

## API Endpoints

1. `POST /users` - Create user
2. `POST /events` - Create event
3. `POST /events/{eventId}/register` - Register user (body: `{"userId": str}`)
4. `DELETE /events/{eventId}/register/{userId}` - Unregister user
5. `GET /users/{userId}/events` - List user's registered events


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Property 1: User creation round trip
*For any* valid userId and name, creating a user then retrieving it returns the same data
**Validates: Requirements 1.1**

Property 2: Duplicate user rejection
*For any* existing userId, creating another user with that ID is rejected
**Validates: Requirements 1.2**

Property 3: Whitespace validation
*For any* whitespace-only string, creating a user with that as userId or name is rejected
**Validates: Requirements 1.3, 1.4**

Property 4: Capacity enforcement
*For any* event with capacity N, the (N+1)th registration is rejected (no waitlist) or waitlisted (with waitlist)
**Validates: Requirements 2.1, 2.4**

Property 5: Invalid capacity rejection
*For any* capacity ≤ 0, event creation is rejected
**Validates: Requirements 2.2**

Property 6: Waitlist ordering
*For any* full event with waitlist, users are added to waitlist in registration order
**Validates: Requirements 2.3, 3.3**

Property 7: Duplicate registration rejection
*For any* user already registered for an event, re-registering is rejected
**Validates: Requirements 3.2**

Property 8: Registration validation
*For any* non-existent user or event, registration is rejected
**Validates: Requirements 3.5, 3.6**

Property 9: Unregistration increases capacity
*For any* registered user, unregistering increases available capacity by one (if waitlist empty)
**Validates: Requirements 4.1**

Property 10: Waitlist promotion
*For any* event with non-empty waitlist, unregistering moves first waitlist user to registered
**Validates: Requirements 4.3**

Property 11: Waitlist removal preserves capacity
*For any* waitlisted user, unregistering doesn't change event capacity
**Validates: Requirements 4.2**

Property 12: Invalid unregistration rejection
*For any* user not associated with an event, unregistering is rejected
**Validates: Requirements 4.4, 4.5**

Property 13: Registered events retrieval
*For any* user, listing events returns only events where user is registered (not waitlisted)
**Validates: Requirements 5.1, 5.2**

Property 14: Non-existent user listing rejection
*For any* non-existent userId, listing events returns an error
**Validates: Requirements 5.4**

## Error Handling

- 400: Validation errors (whitespace, invalid capacity, duplicates)
- 404: Non-existent user/event
- 409: Business logic errors (full event, invalid unregistration)

## Testing Strategy

**Property-Based Testing**: Use Hypothesis (Python) with 100+ iterations per property. Each test tagged with:
`# Feature: user-registration, Property {number}: {property_text}`

**Unit Testing**: Cover specific examples and edge cases to complement property tests.
