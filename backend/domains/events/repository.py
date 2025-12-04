"""Event repository for data access."""

from typing import Dict, Optional, List
from .models import Event


class EventRepository:
    """Repository for managing event data in memory."""
    
    def __init__(self):
        """Initialize the repository with empty storage."""
        self._events: Dict[str, Event] = {}
    
    def create(self, event: Event) -> Event:
        """Create a new event in storage."""
        self._events[event.eventId] = event
        return event
    
    def get(self, event_id: str) -> Optional[Event]:
        """Get an event by ID, returns None if not found."""
        return self._events.get(event_id)
    
    def exists(self, event_id: str) -> bool:
        """Check if an event exists."""
        return event_id in self._events
    
    def update(self, event: Event) -> Event:
        """Update an existing event in storage."""
        self._events[event.eventId] = event
        return event
    
    def list_all(self) -> List[Event]:
        """Get all events."""
        return list(self._events.values())
