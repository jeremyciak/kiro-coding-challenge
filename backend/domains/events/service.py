"""Event service for business logic."""

from .models import Event
from .repository import EventRepository
from core.exceptions import EntityAlreadyExistsError, EntityNotFoundError, ValidationError


class EventService:
    """Service for event business logic."""
    
    def __init__(self, repository: EventRepository):
        """Initialize the service with a repository."""
        self._repository = repository
    
    def create_event(self, event: Event) -> Event:
        """Create a new event."""
        # Validate capacity is greater than zero
        if event.capacity <= 0:
            raise ValidationError("capacity must be greater than zero")
        
        # Check for duplicate eventId
        if self._repository.exists(event.eventId):
            raise EntityAlreadyExistsError(
                f"Event with eventId '{event.eventId}' already exists"
            )
        
        # Initialize registered and waitlist arrays
        event.registered = []
        event.waitlist = []
        
        return self._repository.create(event)
    
    def get_event(self, event_id: str) -> Event:
        """Get an event by ID, raises exception if not found."""
        event = self._repository.get(event_id)
        if event is None:
            raise EntityNotFoundError(
                f"Event with eventId '{event_id}' does not exist"
            )
        return event
    
    def get_event_registrations(self, event_id: str) -> dict:
        """Get registration information for an event."""
        event = self.get_event(event_id)
        return {
            "registered": event.registered,
            "waitlist": event.waitlist,
            "capacity": event.capacity,
            "availableSpots": event.capacity - len(event.registered)
        }
