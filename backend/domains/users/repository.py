"""User repository for data access."""

from typing import Dict, Optional, List
from .models import User


class UserRepository:
    """Repository for managing user data in memory."""
    
    def __init__(self):
        """Initialize the repository with empty storage."""
        self._users: Dict[str, User] = {}
    
    def create(self, user: User) -> User:
        """Create a new user in storage."""
        self._users[user.userId] = user
        return user
    
    def get(self, user_id: str) -> Optional[User]:
        """Get a user by ID, returns None if not found."""
        return self._users.get(user_id)
    
    def exists(self, user_id: str) -> bool:
        """Check if a user exists."""
        return user_id in self._users
    
    def list_all(self) -> List[User]:
        """Get all users."""
        return list(self._users.values())
