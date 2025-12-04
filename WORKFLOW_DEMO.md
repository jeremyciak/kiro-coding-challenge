# User Registration System - Workflow Demonstration

## Visual Workflow Example

This document demonstrates a complete user registration workflow with a real-world scenario.

## Scenario: Tech Conference 2024

**Event Details:**
- Name: Tech Conference 2024
- Capacity: 2 attendees
- Waitlist: Enabled

**Users:**
- Alice Johnson (alice123)
- Bob Smith (bob456)
- Charlie Brown (charlie789)

---

## Step-by-Step Workflow

### Step 1: Create Users

```bash
POST /users
{
  "userId": "alice123",
  "name": "Alice Johnson"
}
→ Response: 201 Created

POST /users
{
  "userId": "bob456",
  "name": "Bob Smith"
}
→ Response: 201 Created

POST /users
{
  "userId": "charlie789",
  "name": "Charlie Brown"
}
→ Response: 201 Created
```

**State:**
```
Users: [alice123, bob456, charlie789]
Events: []
```

---

### Step 2: Create Event

```bash
POST /events
{
  "eventId": "conf2024",
  "name": "Tech Conference 2024",
  "capacity": 2,
  "hasWaitlist": true
}
→ Response: 201 Created
```

**State:**
```
Event: conf2024
├─ Capacity: 2
├─ Registered: []
└─ Waitlist: []
```

---

### Step 3: Alice Registers (Spot 1/2)

```bash
POST /events/conf2024/register
{
  "userId": "alice123"
}
→ Response: 200 OK
{
  "message": "User 'alice123' successfully registered",
  "status": "registered"
}
```

**State:**
```
Event: conf2024
├─ Capacity: 2
├─ Registered: [alice123] ← Alice added
└─ Waitlist: []

Available spots: 1/2
```

---

### Step 4: Bob Registers (Spot 2/2 - FULL)

```bash
POST /events/conf2024/register
{
  "userId": "bob456"
}
→ Response: 200 OK
{
  "message": "User 'bob456' successfully registered",
  "status": "registered"
}
```

**State:**
```
Event: conf2024
├─ Capacity: 2
├─ Registered: [alice123, bob456] ← Bob added
└─ Waitlist: []

Available spots: 0/2 (FULL)
```

---

### Step 5: Charlie Registers (Goes to Waitlist)

```bash
POST /events/conf2024/register
{
  "userId": "charlie789"
}
→ Response: 200 OK
{
  "message": "Event 'conf2024' is full. User 'charlie789' added to waitlist",
  "status": "waitlisted"
}
```

**State:**
```
Event: conf2024
├─ Capacity: 2
├─ Registered: [alice123, bob456]
└─ Waitlist: [charlie789] ← Charlie waitlisted

Available spots: 0/2 (FULL)
Waitlist: 1 person
```

---

### Step 6: Check Alice's Events

```bash
GET /users/alice123/events
→ Response: 200 OK
{
  "events": [
    {
      "eventId": "conf2024",
      "name": "Tech Conference 2024",
      "capacity": 2,
      "hasWaitlist": true,
      "registered": ["alice123", "bob456"],
      "waitlist": ["charlie789"]
    }
  ]
}
```

**Result:** Alice sees 1 registered event ✅

---

### Step 7: Check Bob's Events

```bash
GET /users/bob456/events
→ Response: 200 OK
{
  "events": [
    {
      "eventId": "conf2024",
      "name": "Tech Conference 2024",
      ...
    }
  ]
}
```

**Result:** Bob sees 1 registered event ✅

---

### Step 8: Check Charlie's Events

```bash
GET /users/charlie789/events
→ Response: 200 OK
{
  "events": []
}
```

**Result:** Charlie sees 0 events (waitlisted only, not registered) ✅

---

### Step 9: Alice Unregisters (Charlie Gets Promoted!)

```bash
DELETE /events/conf2024/register/alice123
→ Response: 200 OK
{
  "message": "User 'alice123' unregistered from event 'conf2024'. User 'charlie789' promoted from waitlist",
  "promoted": "charlie789"
}
```

**State Change:**
```
BEFORE:
Event: conf2024
├─ Registered: [alice123, bob456]
└─ Waitlist: [charlie789]

AFTER:
Event: conf2024
├─ Registered: [bob456, charlie789] ← Charlie promoted!
└─ Waitlist: []

Alice removed, Charlie promoted from waitlist
```

---

### Step 10: Verify Charlie's Events After Promotion

```bash
GET /users/charlie789/events
→ Response: 200 OK
{
  "events": [
    {
      "eventId": "conf2024",
      "name": "Tech Conference 2024",
      ...
    }
  ]
}
```

**Result:** Charlie now sees 1 registered event ✅ (promoted from waitlist)

---

### Step 11: Verify Alice's Events After Unregistration

```bash
GET /users/alice123/events
→ Response: 200 OK
{
  "events": []
}
```

**Result:** Alice sees 0 events ✅ (unregistered)

---

## Final State

```
Users:
├─ alice123: 0 registered events
├─ bob456: 1 registered event (conf2024)
└─ charlie789: 1 registered event (conf2024)

Event: conf2024
├─ Capacity: 2
├─ Registered: [bob456, charlie789]
└─ Waitlist: []

Available spots: 0/2 (FULL)
```

---

## Error Handling Examples

### Example 1: Duplicate Registration

```bash
POST /events/conf2024/register
{
  "userId": "bob456"
}
→ Response: 400 Bad Request
{
  "detail": "User 'bob456' is already registered for event 'conf2024'"
}
```

### Example 2: Non-existent User

```bash
POST /events/conf2024/register
{
  "userId": "nonexistent"
}
→ Response: 404 Not Found
{
  "detail": "User with userId 'nonexistent' does not exist"
}
```

### Example 3: Non-existent User Query

```bash
GET /users/nonexistent/events
→ Response: 404 Not Found
{
  "detail": "User with userId 'nonexistent' does not exist"
}
```

### Example 4: Invalid Capacity

```bash
POST /events
{
  "eventId": "invalid",
  "name": "Invalid Event",
  "capacity": 0,
  "hasWaitlist": false
}
→ Response: 400 Bad Request
{
  "detail": "capacity must be greater than zero"
}
```

### Example 5: Full Event Without Waitlist

```bash
# Create event without waitlist
POST /events
{
  "eventId": "workshop",
  "name": "Workshop",
  "capacity": 1,
  "hasWaitlist": false
}

# Fill capacity
POST /events/workshop/register
{"userId": "alice123"}
→ Response: 200 OK (registered)

# Try to register when full
POST /events/workshop/register
{"userId": "bob456"}
→ Response: 409 Conflict
{
  "detail": "Event 'workshop' is at full capacity and does not have a waitlist"
}
```

---

## Key Behaviors Demonstrated

✅ **Capacity Enforcement:** Events respect capacity limits
✅ **Waitlist Management:** Users are waitlisted when events are full
✅ **Automatic Promotion:** Waitlisted users are promoted when spots open
✅ **Event Filtering:** Users only see registered events, not waitlisted ones
✅ **Validation:** All inputs are validated (users, events, capacity)
✅ **Error Handling:** Clear error messages for invalid operations
✅ **State Consistency:** System maintains consistent state across operations

---

## Testing This Workflow

Run the complete workflow test:
```powershell
.\test_registration_workflow.ps1
```

Or run the comprehensive integration test:
```powershell
.\test_integration_final.ps1
```

Both scripts demonstrate this exact workflow against the live API!
