# Design Document

## Overview

This design document outlines the refactoring of the User Registration API from a monolithic single-file structure (`backend/main.py`) to a modular, domain-driven architecture. The refactoring will separate concerns into distinct layers: API handlers, service layer (business logic), repository layer (data access), and data models. The new structure will organize code by domain (users, events, registrations) while maintaining 100% backward compatibility with existing API endpoints.

## Architecture

### Current Architecture

The current implementation consists of a single `backend/main.py` file (~300 lines) containing:
- FastAPI app initialization and middleware
- Pydantic data models (User, Event, RegistrationRequest)
- In-memory storage (dictionaries)
- All API route handlers with embedded business logic
- Validation logic mixed with HTTP handling
- Lambda handler configuration

### Target Architecture

The refactored architecture will follow a layered approach with domain-based organization:

```
backend/
├── main.py                    # FastAPI app, middleware, route registration
├── config.py                  # Application configuration
├── domains/
│   ├── __init__.py
│   ├── users/
│   │   ├── __init__.py
│   │   ├── models.py          # User Pydantic model
│   │   ├── repository.py      # User data access
│   │   ├── service.py         # User business logic
│   │   └── routes.py          # User API handlers
│   ├── events/
│   │   ├── __init__.py
│   │   ├── models.py          # Event Pydantic model
│   │   ├── repository.py      # Event data access
│   │   ├── service.py         # Event business logic
│   │   └── routes.py          # Event API handlers
│   └── registrations/
│       ├── __init__.py
│       ├── models.py          # Registration request models
│       ├── service.py         # Registration business logic
│       └── routes.py          # Registration API handlers
└── core/
    ├── __init__.py
    ├── exceptions.py          # Custom exception classes
    └── dependencies.py        # Shared dependencies
```

### Layer Responsibilities

**API Layer (routes.py)**
- Define FastAPI route decorators and path parameters
- Parse HTTP requests and extract data
- Call service layer functions
- Transform service responses to HTTP responses
- Handle HTTP-specific concerns (status codes, headers)

**Service Layer (service.py)**
- Implement business logic and rules
- Coordinate operations across repositories
- Validate business constraints
- Raise domain-specific exceptions
- Return domain objects or simple data structures

**Repository Layer (repository.py)**
- Provide CRUD operations for entities
- Abstract storage implementation details
- Manage in-memory dictionaries
- Return domain models or None
- Raise repository-specific exceptions for data errors

**Model Layer (models.py)**
- Define Pydantic models for data validation
- Implement field-level validation rules
- Provide data structure definitions
- Support serialization/deserialization

## Components and Interfaces

### User Domain

**models.py**
```python
from pydantic import BaseModel, field_validator

class User(BaseModel):
    userId: str
    name: str
    
    @field_validator('userId', 'name')
    @classmethod
    def validate_not_empty(cls, v: str) -> str:
        if not v or v.strip() == "":
            raise ValueError("cannot be empty or whitespace-only")
        return v
```

**repository.py**
```python
class UserRepository:
    def __init__(self):
        self._users: Dict[str, User] = {}
    
    def create(self, user: User) -> User
    def get(self, user_id: str) -> Optional[User]
    def exists(self, user_id: str) -> bool
    def list_all(self) -> List[User]
```

**service.py**
```python
class UserService:
    def __init__(self, repository: UserRepository):
        self._repository = repository
    
    def create_user(self, user: User) -> User
    def get_user(self, user_id: str) -> User
    def user_exists(self, user_id: str) -> bool
```

**routes.py**
```python
router = APIRouter(prefix="/users", tags=["users"])

@router.post("", status_code=status.HTTP_201_CREATED)
def create_user(user: User, service: UserService = Depends(get_user_service)) -> User
```

### Event Domain

**models.py**
```python
class Event(BaseModel):
    eventId: str
    title: str = None
    name: str = None
    description: str = None
    date: str = None
    location: str = None
    capacity: int
    organizer: str = None
    status: str = None
    waitlistEnabled: bool = None
    hasWaitlist: bool = None
    registered: List[str] = []
    waitlist: List[str] = []
    
    def __init__(self, **data):
        # Field mapping logic for title->name and waitlistEnabled->hasWaitlist
```

**repository.py**
```python
class EventRepository:
    def __init__(self):
        self._events: Dict[str, Event] = {}
    
    def create(self, event: Event) -> Event
    def get(self, event_id: str) -> Optional[Event]
    def exists(self, event_id: str) -> bool
    def update(self, event: Event) -> Event
    def list_all(self) -> List[Event]
```

**service.py**
```python
class EventService:
    def __init__(self, repository: EventRepository):
        self._repository = repository
    
    def create_event(self, event: Event) -> Event
    def get_event(self, event_id: str) -> Event
    def get_event_registrations(self, event_id: str) -> dict
```

**routes.py**
```python
router = APIRouter(prefix="/events", tags=["events"])

@router.post("", status_code=status.HTTP_201_CREATED)
def create_event(event: Event, service: EventService = Depends(get_event_service)) -> Event

@router.get("/{eventId}/registrations")
def get_registrations(eventId: str, service: EventService = Depends(get_event_service)) -> dict
```

### Registration Domain

**models.py**
```python
class RegistrationRequest(BaseModel):
    userId: str

class RegistrationResponse(BaseModel):
    message: str
    status: str = None
    promoted: str = None
```

**service.py**
```python
class RegistrationService:
    def __init__(self, user_repo: UserRepository, event_repo: EventRepository):
        self._user_repo = user_repo
        self._event_repo = event_repo
    
    def register_user(self, event_id: str, user_id: str) -> dict
    def unregister_user(self, event_id: str, user_id: str) -> dict
    def get_user_events(self, user_id: str) -> List[Event]
```

**routes.py**
```python
router = APIRouter(tags=["registrations"])

@router.post("/events/{eventId}/register")
@router.post("/events/{eventId}/registrations", status_code=status.HTTP_201_CREATED)
def register_user(eventId: str, request: RegistrationRequest, 
                  service: RegistrationService = Depends(get_registration_service)) -> dict

@router.delete("/events/{eventId}/register/{userId}")
@router.delete("/events/{eventId}/registrations/{userId}")
def unregister_user(eventId: str, userId: str,
                    service: RegistrationService = Depends(get_registration_service)) -> dict

@router.get("/users/{userId}/events")
@router.get("/users/{userId}/registrations")
def get_user_events(userId: str,
                    service: RegistrationService = Depends(get_registration_service)) -> dict
```

### Core Components

**exceptions.py**
```python
class DomainException(Exception):
    """Base exception for domain errors"""
    pass

class EntityNotFoundError(DomainException):
    """Raised when an entity is not found"""
    pass

class EntityAlreadyExistsError(DomainException):
    """Raised when attempting to create a duplicate entity"""
    pass

class BusinessRuleViolationError(DomainException):
    """Raised when a business rule is violated"""
    pass

class ValidationError(DomainException):
    """Raised when validation fails"""
    pass
```

**dependencies.py**
```python
# Singleton instances for repositories
_user_repository = UserRepository()
_event_repository = EventRepository()

def get_user_repository() -> UserRepository:
    return _user_repository

def get_event_repository() -> EventRepository:
    return _event_repository

def get_user_service() -> UserService:
    return UserService(get_user_repository())

def get_event_service() -> EventService:
    return EventService(get_event_repository())

def get_registration_service() -> RegistrationService:
    return RegistrationService(get_user_repository(), get_event_repository())
```

**main.py**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from domains.users.routes import router as users_router
from domains.events.routes import router as events_router
from domains.registrations.routes import router as registrations_router

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(users_router)
app.include_router(events_router)
app.include_router(registrations_router)

@app.get("/")
def read_root():
    return {"message": "User Registration API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

# Lambda handler
from mangum import Mangum
handler = Mangum(app)
```

## Data Models

### User Model
- `userId`: string (required, non-empty, non-whitespace)
- `name`: string (required, non-empty, non-whitespace)

### Event Model
- `eventId`: string (required, unique)
- `title`: string (optional, maps to name)
- `name`: string (optional)
- `description`: string (optional)
- `date`: string (optional)
- `location`: string (optional)
- `capacity`: integer (required, > 0)
- `organizer`: string (optional)
- `status`: string (optional)
- `waitlistEnabled`: boolean (optional, maps to hasWaitlist)
- `hasWaitlist`: boolean (optional)
- `registered`: List[string] (auto-initialized to [])
- `waitlist`: List[string] (auto-initialized to [])

### RegistrationRequest Model
- `userId`: string (required)

### RegistrationResponse Model
- `message`: string (required)
- `status`: string (optional, "registered" or "waitlisted")
- `promoted`: string (optional, userId of promoted user)

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Business logic isolation

*For any* API request, when the request is processed, the service layer should execute business logic without direct access to HTTP request or response objects.

**Validates: Requirements 1.2, 1.3**

### Property 2: Repository interface consistency

*For any* entity type (User, Event), the repository should provide create, read, and exists operations with consistent method signatures and return types.

**Validates: Requirements 2.2, 2.5**

### Property 3: Domain organization completeness

*For any* domain directory (users, events, registrations), the directory should contain all necessary modules (models, repository, service, routes) for that domain's functionality.

**Validates: Requirements 3.2**

### Property 4: Endpoint path preservation

*For any* existing API endpoint, after refactoring, the endpoint path and HTTP method should remain identical to the original implementation.

**Validates: Requirements 4.1**

### Property 5: Response structure preservation

*For any* API endpoint, when a request is processed, the response structure (fields, types, status codes) should match the original implementation exactly.

**Validates: Requirements 4.2**

### Property 6: Validation rule preservation

*For any* input validation, the refactored implementation should enforce the same validation rules and produce identical error messages as the original implementation.

**Validates: Requirements 4.3**

### Property 7: Business operation equivalence

*For any* business operation (register, unregister, create user, create event), the refactored implementation should produce identical state changes and side effects as the original implementation.

**Validates: Requirements 4.4**

### Property 8: Model centralization

*For any* Pydantic model, the model definition should exist in exactly one location within its domain's models.py file.

**Validates: Requirements 5.1, 5.2**

### Property 9: Main file simplicity

*For any* implementation detail (business logic, data access, validation), the main.py file should not contain that detail directly, only route registration and configuration.

**Validates: Requirements 6.1, 6.2**

### Property 10: Error handling consistency

*For any* error condition, the refactored implementation should return the same HTTP status code and error message structure as the original implementation.

**Validates: Requirements 7.4**

### Property 11: Storage behavior preservation

*For any* data operation, the refactored implementation should use in-memory dictionaries with the same lifecycle and sharing behavior as the original implementation.

**Validates: Requirements 8.1, 8.2, 8.4**

## Error Handling

### Exception Hierarchy

The application will use a custom exception hierarchy defined in `core/exceptions.py`:

- `DomainException`: Base class for all domain exceptions
  - `EntityNotFoundError`: Entity does not exist (maps to 404)
  - `EntityAlreadyExistsError`: Duplicate entity (maps to 400)
  - `BusinessRuleViolationError`: Business rule violated (maps to 409)
  - `ValidationError`: Validation failed (maps to 400)

### Exception Flow

1. **Service Layer**: Raises domain-specific exceptions when business rules are violated
2. **API Layer**: Catches domain exceptions and translates to HTTPException with appropriate status codes
3. **FastAPI**: Handles HTTPException and returns formatted error responses

### Error Mapping

| Domain Exception | HTTP Status | Use Case |
|-----------------|-------------|----------|
| EntityNotFoundError | 404 | User or event not found |
| EntityAlreadyExistsError | 400 | Duplicate userId or eventId |
| BusinessRuleViolationError | 409 | Event full, already registered |
| ValidationError | 400 | Invalid input (whitespace, capacity <= 0) |
| Pydantic ValidationError | 422 | Invalid request body format |

### Error Response Format

All errors will maintain the current FastAPI error response format:
```json
{
  "detail": "Error message describing the issue"
}
```

## Testing Strategy

### Unit Testing

Unit tests will verify individual components in isolation:

**Repository Tests**
- Test CRUD operations for each repository
- Verify in-memory storage behavior
- Test edge cases (empty storage, duplicate keys)

**Service Tests**
- Test business logic with mocked repositories
- Verify exception raising for business rule violations
- Test coordination between multiple repositories

**Route Tests**
- Test HTTP request/response handling
- Verify status codes and response structures
- Test error handling and exception translation

### Integration Testing

Integration tests will verify end-to-end functionality:

**API Endpoint Tests**
- Use existing PowerShell test scripts
- Verify all endpoints return expected responses
- Test complete workflows (create user, create event, register, unregister)
- Ensure backward compatibility with original implementation

**Regression Tests**
- Run existing test suite against refactored code
- Compare responses byte-for-byte with original implementation
- Verify no changes to API behavior

### Property-Based Testing

Property-based tests will verify correctness properties:

**Testing Framework**: Hypothesis (Python property-based testing library)

**Test Configuration**: Each property test will run a minimum of 100 iterations

**Property Test Tagging**: Each test will include a comment with format:
`# Feature: code-organization, Property {number}: {property_text}`

**Test Coverage**:
- Property 4: Generate random endpoint paths and verify they exist in both implementations
- Property 5: Generate random valid requests and compare response structures
- Property 6: Generate random invalid inputs and verify identical validation errors
- Property 7: Generate random operation sequences and verify identical final states
- Property 11: Generate random data operations and verify storage behavior

### Test Execution Strategy

1. **During Refactoring**: Write unit tests for each new module as it's created
2. **After Module Completion**: Run integration tests to verify endpoint functionality
3. **Before Completion**: Run full regression suite with existing PowerShell scripts
4. **Final Validation**: Execute property-based tests to verify correctness properties

### Test Organization

```
backend/
├── tests/
│   ├── __init__.py
│   ├── unit/
│   │   ├── test_user_repository.py
│   │   ├── test_user_service.py
│   │   ├── test_event_repository.py
│   │   ├── test_event_service.py
│   │   ├── test_registration_service.py
│   │   └── test_routes.py
│   ├── integration/
│   │   ├── test_user_endpoints.py
│   │   ├── test_event_endpoints.py
│   │   └── test_registration_endpoints.py
│   └── property/
│       ├── test_endpoint_preservation.py
│       ├── test_response_structure.py
│       ├── test_validation_rules.py
│       └── test_operation_equivalence.py
```

## Migration Strategy

### Phase 1: Create Domain Structure
- Create directory structure
- Set up `__init__.py` files
- Create core exceptions module

### Phase 2: Extract Models
- Move User model to `domains/users/models.py`
- Move Event model to `domains/events/models.py`
- Create RegistrationRequest in `domains/registrations/models.py`
- Verify models work identically

### Phase 3: Create Repositories
- Implement UserRepository with in-memory storage
- Implement EventRepository with in-memory storage
- Create singleton instances in dependencies.py
- Test repository operations

### Phase 4: Extract Service Layer
- Implement UserService with business logic
- Implement EventService with business logic
- Implement RegistrationService with business logic
- Test service operations with mocked repositories

### Phase 5: Refactor Routes
- Create route handlers in domain route files
- Implement dependency injection
- Translate service exceptions to HTTP exceptions
- Test each endpoint individually

### Phase 6: Update Main File
- Remove old code from main.py
- Register domain routers
- Keep middleware and configuration
- Verify all endpoints work

### Phase 7: Validation
- Run existing PowerShell test scripts
- Verify all tests pass
- Compare responses with original implementation
- Deploy and test in AWS environment

## Deployment Considerations

### Lambda Deployment Package

The refactored code will be deployed to AWS Lambda. Considerations:

1. **Import Paths**: All imports must use relative or absolute paths correctly
2. **File Structure**: The `backend_deploy` directory will mirror the new structure
3. **Dependencies**: No new dependencies required (FastAPI, Pydantic, Mangum remain)
4. **Handler**: The `handler` export in main.py must remain for Lambda

### Backward Compatibility

The refactoring maintains 100% backward compatibility:
- All endpoint paths unchanged
- All request/response formats unchanged
- All validation rules unchanged
- All error messages unchanged
- In-memory storage behavior unchanged

### Performance

The refactored architecture should have negligible performance impact:
- Additional function calls (service layer) are minimal overhead
- No new I/O operations introduced
- In-memory storage remains the same
- FastAPI routing unchanged

## Future Enhancements

While not part of this refactoring, the new architecture enables:

1. **Database Integration**: Replace repository implementations with database access
2. **Caching**: Add caching layer in repositories
3. **Testing**: Easier unit testing with dependency injection
4. **Feature Addition**: Clear structure for adding new domains
5. **API Versioning**: Easier to version APIs with separated layers
