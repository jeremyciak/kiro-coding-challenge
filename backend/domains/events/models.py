"""Event domain models."""

from pydantic import BaseModel
from typing import List, Optional


class Event(BaseModel):
    """Event model with field mapping support."""
    eventId: str
    title: Optional[str] = None
    name: Optional[str] = None
    description: Optional[str] = None
    date: Optional[str] = None
    location: Optional[str] = None
    capacity: int
    organizer: Optional[str] = None
    status: Optional[str] = None
    waitlistEnabled: Optional[bool] = None
    hasWaitlist: Optional[bool] = None
    registered: List[str] = []
    waitlist: List[str] = []
    
    def __init__(self, **data):
        """Initialize event with field mapping."""
        # Map title to name if title is provided
        if 'title' in data and data['title']:
            data['name'] = data['title']
        # Map waitlistEnabled to hasWaitlist
        if 'waitlistEnabled' in data:
            data['hasWaitlist'] = data['waitlistEnabled']
        elif 'hasWaitlist' not in data:
            data['hasWaitlist'] = False
        super().__init__(**data)
