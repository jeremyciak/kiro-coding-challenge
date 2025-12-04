"""User domain models."""

from pydantic import BaseModel, field_validator


class User(BaseModel):
    """User model with validation."""
    userId: str
    name: str
    
    @field_validator('userId', 'name')
    @classmethod
    def validate_not_empty(cls, v: str) -> str:
        """Validate that fields are not empty or whitespace-only."""
        if not v or v.strip() == "":
            raise ValueError("cannot be empty or whitespace-only")
        return v
