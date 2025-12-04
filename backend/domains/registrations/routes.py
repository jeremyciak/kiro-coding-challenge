"""Registration API routes."""

from fastapi import APIRouter, HTTPException, status, Depends
from .models import RegistrationRequest
from .service import RegistrationService
from core.exceptions import EntityNotFoundError, BusinessRuleViolationError


router = APIRouter(tags=["registrations"])


def get_registration_service() -> RegistrationService:
    """Dependency to get registration service."""
    from core.dependencies import get_registration_service as _get_service
    return _get_service()


@router.post("/events/{eventId}/register", status_code=status.HTTP_200_OK)
@router.post("/events/{eventId}/registrations", status_code=status.HTTP_201_CREATED)
def register_user(
    eventId: str,
    request: RegistrationRequest,
    service: RegistrationService = Depends(get_registration_service)
) -> dict:
    """Register a user for an event."""
    try:
        return service.register_user(eventId, request.userId)
    except EntityNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except BusinessRuleViolationError as e:
        # Check if it's a capacity error or already registered error
        if "already registered" in str(e):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=str(e)
            )


@router.delete("/events/{eventId}/register/{userId}", status_code=status.HTTP_200_OK)
@router.delete("/events/{eventId}/registrations/{userId}", status_code=status.HTTP_200_OK)
def unregister_user(
    eventId: str,
    userId: str,
    service: RegistrationService = Depends(get_registration_service)
) -> dict:
    """Unregister a user from an event."""
    try:
        return service.unregister_user(eventId, userId)
    except EntityNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except BusinessRuleViolationError as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e)
        )


@router.get("/users/{userId}/events", status_code=status.HTTP_200_OK)
@router.get("/users/{userId}/registrations", status_code=status.HTTP_200_OK)
def get_user_events(
    userId: str,
    service: RegistrationService = Depends(get_registration_service)
) -> dict:
    """Get all events a user is registered for."""
    try:
        events = service.get_user_events(userId)
        return {"events": events}
    except EntityNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
