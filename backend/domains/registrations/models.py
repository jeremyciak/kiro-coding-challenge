"""Registration domain models."""

from pydantic import BaseModel
from typing import Optional


class RegistrationRequest(BaseModel):
    """Request model for user registration."""
    userId: str


class RegistrationResponse(BaseModel):
    """Response model for registration operations."""
    message: str
    status: Optional[str] = None
    promoted: Optional[str] = None
