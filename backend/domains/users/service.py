"""User service for business logic."""

from .models import User
from .repository import UserRepository
from core.exceptions import EntityAlreadyExistsError, EntityNotFoundError


class UserService:
    """Service for user business logic."""
    
    def __init__(self, repository: UserRepository):
        """Initialize the service with a repository."""
        self._repository = repository
    
    def create_user(self, user: User) -> User:
        """Create a new user."""
        # Check for duplicate userId
        if self._repository.exists(user.userId):
            raise EntityAlreadyExistsError(
                f"User with userId '{user.userId}' already exists"
            )
        
        return self._repository.create(user)
    
    def get_user(self, user_id: str) -> User:
        """Get a user by ID, raises exception if not found."""
        user = self._repository.get(user_id)
        if user is None:
            raise EntityNotFoundError(
                f"User with userId '{user_id}' does not exist"
            )
        return user
    
    def user_exists(self, user_id: str) -> bool:
        """Check if a user exists."""
        return self._repository.exists(user_id)
