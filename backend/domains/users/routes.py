"""User API routes."""

from fastapi import APIRouter, HTTPException, status, Depends
from .models import User
from .service import UserService
from core.exceptions import EntityAlreadyExistsError, EntityNotFoundError
from pydantic import ValidationError


router = APIRouter(prefix="/users", tags=["users"])


def get_user_service() -> UserService:
    """Dependency to get user service."""
    from core.dependencies import get_user_service as _get_service
    return _get_service()


@router.post("", status_code=status.HTTP_201_CREATED)
def create_user(user: User, service: UserService = Depends(get_user_service)) -> User:
    """Create a new user."""
    try:
        return service.create_user(user)
    except EntityAlreadyExistsError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except ValidationError as e:
        # Handle Pydantic validation errors
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
