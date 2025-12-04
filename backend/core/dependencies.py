"""Dependency injection for services and repositories."""

from domains.users.repository import UserRepository
from domains.users.service import UserService
from domains.events.repository import EventRepository
from domains.events.service import EventService
from domains.registrations.service import RegistrationService


# Singleton instances for repositories
_user_repository = UserRepository()
_event_repository = EventRepository()


def get_user_repository() -> UserRepository:
    """Get the singleton user repository instance."""
    return _user_repository


def get_event_repository() -> EventRepository:
    """Get the singleton event repository instance."""
    return _event_repository


def get_user_service() -> UserService:
    """Get a user service instance."""
    return UserService(get_user_repository())


def get_event_service() -> EventService:
    """Get an event service instance."""
    return EventService(get_event_repository())


def get_registration_service() -> RegistrationService:
    """Get a registration service instance."""
    return RegistrationService(get_user_repository(), get_event_repository())
