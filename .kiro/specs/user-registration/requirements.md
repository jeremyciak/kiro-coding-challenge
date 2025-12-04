# Requirements Document

## Introduction

This document specifies the requirements for a user registration system that allows users to register for events with capacity constraints and waitlist management. The system enables users to create profiles, register for events, manage their registrations, and handle event capacity limits with optional waitlist functionality.

## Glossary

- **User**: An individual with a unique identifier and name who can register for events
- **Event**: A scheduled activity with a defined capacity constraint and optional waitlist
- **Registration**: The act of a user signing up to attend an event
- **Capacity**: The maximum number of users that can be registered for an event
- **Waitlist**: An ordered list of users waiting for availability when an event reaches capacity
- **System**: The user registration management application

## Requirements

### Requirement 1

**User Story:** As a system administrator, I want to create user profiles with basic information, so that users can be identified and tracked within the system.

#### Acceptance Criteria

1. WHEN a user is created with a userId and name THEN the System SHALL store the user information and make it available for future operations
2. WHEN a user is created with a userId that already exists THEN the System SHALL reject the creation and return an error
3. WHEN a user is created with an empty or whitespace-only name THEN the System SHALL reject the creation and return an error
4. WHEN a user is created with an empty or whitespace-only userId THEN the System SHALL reject the creation and return an error

### Requirement 2

**User Story:** As an event organizer, I want to configure events with capacity constraints and optional waitlists, so that I can manage attendance limits and handle overflow demand.

#### Acceptance Criteria

1. WHEN an event is created with a capacity value THEN the System SHALL enforce that capacity as the maximum number of registered users
2. WHEN an event is created with a capacity less than or equal to zero THEN the System SHALL reject the creation and return an error
3. WHEN an event is configured with a waitlist enabled THEN the System SHALL maintain an ordered waitlist for users when capacity is reached
4. WHEN an event is configured without a waitlist THEN the System SHALL reject registration attempts after capacity is reached

### Requirement 3

**User Story:** As a user, I want to register for events, so that I can secure my attendance at activities I'm interested in.

#### Acceptance Criteria

1. WHEN a user registers for an event that has available capacity THEN the System SHALL add the user to the event registration list and decrease available capacity by one
2. WHEN a user attempts to register for an event they are already registered for THEN the System SHALL reject the registration and return an error
3. WHEN a user registers for an event at full capacity with waitlist enabled THEN the System SHALL add the user to the waitlist in order of registration attempt
4. WHEN a user attempts to register for an event at full capacity without waitlist enabled THEN the System SHALL reject the registration and return an error
5. WHEN a user attempts to register for a non-existent event THEN the System SHALL reject the registration and return an error
6. WHEN a non-existent user attempts to register for an event THEN the System SHALL reject the registration and return an error

### Requirement 4

**User Story:** As a user, I want to unregister from events, so that I can free up my spot if I can no longer attend.

#### Acceptance Criteria

1. WHEN a registered user unregisters from an event THEN the System SHALL remove the user from the registration list and increase available capacity by one
2. WHEN a user on the waitlist unregisters from an event THEN the System SHALL remove the user from the waitlist without affecting event capacity
3. WHEN a registered user unregisters from an event with a non-empty waitlist THEN the System SHALL move the first user from the waitlist to the registration list
4. WHEN a user attempts to unregister from an event they are not registered for or waitlisted for THEN the System SHALL reject the unregistration and return an error
5. WHEN a user attempts to unregister from a non-existent event THEN the System SHALL reject the unregistration and return an error

### Requirement 5

**User Story:** As a user, I want to view all events I am registered for, so that I can keep track of my commitments.

#### Acceptance Criteria

1. WHEN a user requests their registered events THEN the System SHALL return a list of all events where the user is in the registration list
2. WHEN a user requests their registered events THEN the System SHALL exclude events where the user is only on the waitlist
3. WHEN a user with no registrations requests their registered events THEN the System SHALL return an empty list
4. WHEN a non-existent user requests their registered events THEN the System SHALL return an error
