"""Event API routes."""

from fastapi import APIRouter, HTTPException, status, Depends
from .models import Event
from .service import EventService
from core.exceptions import EntityAlreadyExistsError, EntityNotFoundError, ValidationError


router = APIRouter(prefix="/events", tags=["events"])


def get_event_service() -> EventService:
    """Dependency to get event service."""
    from core.dependencies import get_event_service as _get_service
    return _get_service()


@router.post("", status_code=status.HTTP_201_CREATED)
def create_event(event: Event, service: EventService = Depends(get_event_service)) -> Event:
    """Create a new event."""
    try:
        return service.create_event(event)
    except EntityAlreadyExistsError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except ValidationError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.get("/{eventId}/registrations", status_code=status.HTTP_200_OK)
def get_event_registrations(eventId: str, service: EventService = Depends(get_event_service)) -> dict:
    """Get all registrations for an event."""
    try:
        return service.get_event_registrations(eventId)
    except EntityNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
