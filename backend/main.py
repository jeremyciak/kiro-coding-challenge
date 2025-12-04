from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, List

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class User(BaseModel):
    userId: str
    name: str

class Event(BaseModel):
    eventId: str
    title: str = None  # Optional, maps to 'name' internally
    name: str = None   # Internal field
    description: str = None
    date: str = None
    location: str = None
    capacity: int
    organizer: str = None
    status: str = None
    waitlistEnabled: bool = None  # Maps to hasWaitlist
    hasWaitlist: bool = None      # Internal field
    registered: List[str] = []
    waitlist: List[str] = []
    
    def __init__(self, **data):
        # Map title to name if title is provided
        if 'title' in data and data['title']:
            data['name'] = data['title']
        # Map waitlistEnabled to hasWaitlist
        if 'waitlistEnabled' in data:
            data['hasWaitlist'] = data['waitlistEnabled']
        elif 'hasWaitlist' not in data:
            data['hasWaitlist'] = False
        super().__init__(**data)

# In-memory storage
users: Dict[str, User] = {}
events: Dict[str, Event] = {}

@app.get("/")
def read_root():
    return {"message": "User Registration API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.post("/users", status_code=status.HTTP_201_CREATED)
def create_user(user: User):
    # Validate userId is not empty or whitespace-only
    if not user.userId or user.userId.strip() == "":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="userId cannot be empty or whitespace-only"
        )
    
    # Validate name is not empty or whitespace-only
    if not user.name or user.name.strip() == "":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="name cannot be empty or whitespace-only"
        )
    
    # Check for duplicate userId
    if user.userId in users:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"User with userId '{user.userId}' already exists"
        )
    
    # Store the user
    users[user.userId] = user
    return user

@app.post("/events", status_code=status.HTTP_201_CREATED)
def create_event(event: Event):
    # Validate capacity is greater than zero
    if event.capacity <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="capacity must be greater than zero"
        )
    
    # Check for duplicate eventId
    if event.eventId in events:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Event with eventId '{event.eventId}' already exists"
        )
    
    # Initialize registered and waitlist arrays (already done in model defaults)
    event.registered = []
    event.waitlist = []
    
    # Store the event
    events[event.eventId] = event
    return event

class RegistrationRequest(BaseModel):
    userId: str

@app.post("/events/{eventId}/register", status_code=status.HTTP_200_OK)
@app.post("/events/{eventId}/registrations", status_code=status.HTTP_201_CREATED)
def register_user(eventId: str, request: RegistrationRequest):
    userId = request.userId
    
    # Check if user exists (Requirement 3.6)
    if userId not in users:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with userId '{userId}' does not exist"
        )
    
    # Check if event exists (Requirement 3.5)
    if eventId not in events:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with eventId '{eventId}' does not exist"
        )
    
    event = events[eventId]
    
    # Check if user is already registered (Requirement 3.2)
    if userId in event.registered or userId in event.waitlist:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"User '{userId}' is already registered for event '{eventId}'"
        )
    
    # Check if event has available capacity (Requirement 3.1)
    if len(event.registered) < event.capacity:
        # Add user to registered list
        event.registered.append(userId)
        return {"message": f"User '{userId}' successfully registered for event '{eventId}'", "status": "registered"}
    
    # Event is at full capacity
    if event.hasWaitlist:
        # Add user to waitlist (Requirement 3.3)
        event.waitlist.append(userId)
        return {"message": f"Event '{eventId}' is full. User '{userId}' added to waitlist", "status": "waitlisted"}
    else:
        # Reject registration (Requirement 3.4)
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Event '{eventId}' is at full capacity and does not have a waitlist"
        )

@app.delete("/events/{eventId}/register/{userId}", status_code=status.HTTP_200_OK)
@app.delete("/events/{eventId}/registrations/{userId}", status_code=status.HTTP_200_OK)
def unregister_user(eventId: str, userId: str):
    # Check if event exists (Requirement 4.5)
    if eventId not in events:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with eventId '{eventId}' does not exist"
        )
    
    event = events[eventId]
    
    # Check if user is in registered list
    if userId in event.registered:
        # Remove user from registered list (Requirement 4.1)
        event.registered.remove(userId)
        
        # Check if there's a waitlist to promote from (Requirement 4.3)
        if event.waitlist:
            # Move first user from waitlist to registered
            promoted_user = event.waitlist.pop(0)
            event.registered.append(promoted_user)
            return {
                "message": f"User '{userId}' unregistered from event '{eventId}'. User '{promoted_user}' promoted from waitlist",
                "promoted": promoted_user
            }
        else:
            # No waitlist, capacity simply increases
            return {"message": f"User '{userId}' successfully unregistered from event '{eventId}'"}
    
    # Check if user is in waitlist
    elif userId in event.waitlist:
        # Remove user from waitlist (Requirement 4.2)
        event.waitlist.remove(userId)
        return {"message": f"User '{userId}' removed from waitlist for event '{eventId}'"}
    
    # User is not associated with the event (Requirement 4.4)
    else:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"User '{userId}' is not registered or waitlisted for event '{eventId}'"
        )

@app.get("/events/{eventId}/registrations", status_code=status.HTTP_200_OK)
def get_event_registrations(eventId: str):
    # Check if event exists
    if eventId not in events:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with eventId '{eventId}' does not exist"
        )
    
    event = events[eventId]
    return {
        "registered": event.registered,
        "waitlist": event.waitlist,
        "capacity": event.capacity,
        "availableSpots": event.capacity - len(event.registered)
    }

@app.get("/users/{userId}/events", status_code=status.HTTP_200_OK)
@app.get("/users/{userId}/registrations", status_code=status.HTTP_200_OK)
def get_user_events(userId: str):
    # Validate user existence (Requirement 5.4)
    if userId not in users:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with userId '{userId}' does not exist"
        )
    
    # Filter events where user is in registered list (Requirements 5.1, 5.2)
    registered_events = []
    for event_id, event in events.items():
        # Only include events where user is registered, not waitlisted (Requirement 5.2)
        if userId in event.registered:
            registered_events.append(event)
    
    # Return list of registered events (Requirement 5.3 - empty list if no registrations)
    return {"events": registered_events}


# Lambda handler
from mangum import Mangum
handler = Mangum(app)
