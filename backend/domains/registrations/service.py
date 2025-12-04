"""Registration service for business logic."""

from typing import List
from domains.users.repository import UserRepository
from domains.events.repository import EventRepository
from domains.events.models import Event
from core.exceptions import EntityNotFoundError, BusinessRuleViolationError


class RegistrationService:
    """Service for registration business logic."""
    
    def __init__(self, user_repo: UserRepository, event_repo: EventRepository):
        """Initialize the service with repositories."""
        self._user_repo = user_repo
        self._event_repo = event_repo
    
    def register_user(self, event_id: str, user_id: str) -> dict:
        """Register a user for an event."""
        # Check if user exists
        if not self._user_repo.exists(user_id):
            raise EntityNotFoundError(
                f"User with userId '{user_id}' does not exist"
            )
        
        # Check if event exists
        event = self._event_repo.get(event_id)
        if event is None:
            raise EntityNotFoundError(
                f"Event with eventId '{event_id}' does not exist"
            )
        
        # Check if user is already registered
        if user_id in event.registered or user_id in event.waitlist:
            raise BusinessRuleViolationError(
                f"User '{user_id}' is already registered for event '{event_id}'"
            )
        
        # Check if event has available capacity
        if len(event.registered) < event.capacity:
            # Add user to registered list
            event.registered.append(user_id)
            self._event_repo.update(event)
            return {
                "message": f"User '{user_id}' successfully registered for event '{event_id}'",
                "status": "registered"
            }
        
        # Event is at full capacity
        if event.hasWaitlist:
            # Add user to waitlist
            event.waitlist.append(user_id)
            self._event_repo.update(event)
            return {
                "message": f"Event '{event_id}' is full. User '{user_id}' added to waitlist",
                "status": "waitlisted"
            }
        else:
            # Reject registration
            raise BusinessRuleViolationError(
                f"Event '{event_id}' is at full capacity and does not have a waitlist"
            )
    
    def unregister_user(self, event_id: str, user_id: str) -> dict:
        """Unregister a user from an event."""
        # Check if event exists
        event = self._event_repo.get(event_id)
        if event is None:
            raise EntityNotFoundError(
                f"Event with eventId '{event_id}' does not exist"
            )
        
        # Check if user is in registered list
        if user_id in event.registered:
            # Remove user from registered list
            event.registered.remove(user_id)
            
            # Check if there's a waitlist to promote from
            if event.waitlist:
                # Move first user from waitlist to registered
                promoted_user = event.waitlist.pop(0)
                event.registered.append(promoted_user)
                self._event_repo.update(event)
                return {
                    "message": f"User '{user_id}' unregistered from event '{event_id}'. User '{promoted_user}' promoted from waitlist",
                    "promoted": promoted_user
                }
            else:
                # No waitlist, capacity simply increases
                self._event_repo.update(event)
                return {
                    "message": f"User '{user_id}' successfully unregistered from event '{event_id}'"
                }
        
        # Check if user is in waitlist
        elif user_id in event.waitlist:
            # Remove user from waitlist
            event.waitlist.remove(user_id)
            self._event_repo.update(event)
            return {
                "message": f"User '{user_id}' removed from waitlist for event '{event_id}'"
            }
        
        # User is not associated with the event
        else:
            raise BusinessRuleViolationError(
                f"User '{user_id}' is not registered or waitlisted for event '{event_id}'"
            )
    
    def get_user_events(self, user_id: str) -> List[Event]:
        """Get all events a user is registered for."""
        # Validate user existence
        if not self._user_repo.exists(user_id):
            raise EntityNotFoundError(
                f"User with userId '{user_id}' does not exist"
            )
        
        # Filter events where user is in registered list
        registered_events = []
        for event in self._event_repo.list_all():
            # Only include events where user is registered, not waitlisted
            if user_id in event.registered:
                registered_events.append(event)
        
        return registered_events
