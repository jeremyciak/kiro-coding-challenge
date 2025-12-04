# Implementation Plan

- [x] 1. Create project structure and core modules


  - Create `backend/domains/` directory with `__init__.py`
  - Create `backend/core/` directory with `__init__.py`
  - Create domain subdirectories: `users/`, `events/`, `registrations/`
  - Add `__init__.py` to each domain directory
  - _Requirements: 3.1, 3.2, 3.3_



- [ ] 2. Implement core exception classes
  - Create `backend/core/exceptions.py` with custom exception hierarchy
  - Define `DomainException`, `EntityNotFoundError`, `EntityAlreadyExistsError`, `BusinessRuleViolationError`, `ValidationError`


  - _Requirements: 7.1, 7.2_

- [ ] 3. Extract and implement User domain
- [ ] 3.1 Create User model
  - Create `backend/domains/users/models.py`
  - Move User Pydantic model with field validators
  - _Requirements: 5.1, 5.2, 1.4_

- [x] 3.2 Implement User repository


  - Create `backend/domains/users/repository.py`
  - Implement `UserRepository` class with in-memory storage
  - Implement methods: `create()`, `get()`, `exists()`, `list_all()`
  - _Requirements: 2.1, 2.2, 2.5, 8.1, 8.2_




- [ ] 3.3 Implement User service
  - Create `backend/domains/users/service.py`
  - Implement `UserService` class with business logic



  - Implement methods: `create_user()`, `get_user()`, `user_exists()`
  - Add validation and exception handling
  - _Requirements: 1.1, 1.2, 1.3, 7.1_

- [x] 3.4 Create User routes


  - Create `backend/domains/users/routes.py`
  - Implement POST `/users` endpoint
  - Add dependency injection for UserService


  - Translate service exceptions to HTTP exceptions
  - _Requirements: 1.2, 4.1, 4.2, 7.3_

- [x] 4. Extract and implement Event domain



- [ ] 4.1 Create Event model
  - Create `backend/domains/events/models.py`
  - Move Event Pydantic model with field mapping logic (title->name, waitlistEnabled->hasWaitlist)
  - _Requirements: 5.1, 5.2_



- [ ] 4.2 Implement Event repository
  - Create `backend/domains/events/repository.py`
  - Implement `EventRepository` class with in-memory storage
  - Implement methods: `create()`, `get()`, `exists()`, `update()`, `list_all()`
  - _Requirements: 2.1, 2.2, 2.5, 8.1, 8.2_



- [ ] 4.3 Implement Event service
  - Create `backend/domains/events/service.py`
  - Implement `EventService` class with business logic
  - Implement methods: `create_event()`, `get_event()`, `get_event_registrations()`



  - Add validation and exception handling
  - _Requirements: 1.1, 1.2, 1.3, 7.1_

- [ ] 4.4 Create Event routes
  - Create `backend/domains/events/routes.py`



  - Implement POST `/events` endpoint
  - Implement GET `/events/{eventId}/registrations` endpoint
  - Add dependency injection for EventService
  - Translate service exceptions to HTTP exceptions
  - _Requirements: 1.2, 4.1, 4.2, 7.3_



- [ ] 5. Extract and implement Registration domain
- [ ] 5.1 Create Registration models
  - Create `backend/domains/registrations/models.py`
  - Move RegistrationRequest model


  - Create RegistrationResponse model
  - _Requirements: 5.1, 5.2_

- [ ] 5.2 Implement Registration service
  - Create `backend/domains/registrations/service.py`
  - Implement `RegistrationService` class with business logic
  - Implement methods: `register_user()`, `unregister_user()`, `get_user_events()`
  - Add all registration business rules (capacity check, waitlist logic, promotion)
  - Add validation and exception handling


  - _Requirements: 1.1, 1.2, 1.3, 7.1_

- [ ] 5.3 Create Registration routes
  - Create `backend/domains/registrations/routes.py`


  - Implement POST `/events/{eventId}/register` and `/events/{eventId}/registrations` endpoints
  - Implement DELETE `/events/{eventId}/register/{userId}` and `/events/{eventId}/registrations/{userId}` endpoints
  - Implement GET `/users/{userId}/events` and `/users/{userId}/registrations` endpoints
  - Add dependency injection for RegistrationService
  - Translate service exceptions to HTTP exceptions
  - _Requirements: 1.2, 4.1, 4.2, 7.3_

- [ ] 6. Create dependency injection module
  - Create `backend/core/dependencies.py`
  - Implement singleton repository instances
  - Implement dependency functions: `get_user_repository()`, `get_event_repository()`, `get_user_service()`, `get_event_service()`, `get_registration_service()`
  - _Requirements: 2.4, 8.4_

- [ ] 7. Refactor main application file
  - Update `backend/main.py` to import domain routers
  - Remove all old model, storage, and route handler code
  - Keep FastAPI app initialization, CORS middleware, and Lambda handler
  - Register domain routers with `app.include_router()`
  - Keep root `/` and `/health` endpoints
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 8. Checkpoint - Verify all endpoints work
  - Ensure all tests pass, ask the user if questions arise

- [ ] 9. Update deployment package structure
  - Copy refactored code structure to `backend_deploy/` directory
  - Ensure all new modules are included
  - Verify import paths work in deployment package
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 10. Run integration tests
  - Execute existing PowerShell test scripts
  - Verify all endpoints return expected responses
  - Confirm backward compatibility
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 11. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise
