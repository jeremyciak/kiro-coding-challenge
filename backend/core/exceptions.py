"""Custom exception classes for domain errors."""


class DomainException(Exception):
    """Base exception for all domain errors."""
    pass


class EntityNotFoundError(DomainException):
    """Raised when an entity is not found."""
    pass


class EntityAlreadyExistsError(DomainException):
    """Raised when attempting to create a duplicate entity."""
    pass


class BusinessRuleViolationError(DomainException):
    """Raised when a business rule is violated."""
    pass


class ValidationError(DomainException):
    """Raised when validation fails."""
    pass
