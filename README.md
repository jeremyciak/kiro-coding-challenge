# User Registration API

A serverless REST API for user registration with capacity-constrained events and waitlist management, built with FastAPI and deployed on AWS using Lambda and API Gateway.

## Architecture

- **Backend**: FastAPI with Python 3.11
- **Storage**: In-memory (suitable for MVP/testing)
- **Infrastructure**: AWS CDK (Python)
- **Deployment**: API Gateway + Lambda (serverless)

## Features

- User profile management
- Event creation with capacity constraints
- User registration with automatic capacity tracking
- Optional waitlist support for full events
- Automatic waitlist promotion on unregistration
- Query user's registered events
- Input validation with Pydantic
- CORS enabled for web access
- Serverless architecture for scalability

## API Endpoint

**Base URL**: https://ze500yz351.execute-api.us-west-2.amazonaws.com/prod/

## Setup Instructions

### Prerequisites

- Python 3.11+
- Node.js (for AWS CDK)
- AWS CLI configured with credentials

### Backend Development

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### Infrastructure Deployment

```bash
cd infrastructure
pip install -r requirements.txt
cdk bootstrap  # First time only
cdk deploy
```

## API Usage

### Create User
```bash
POST /users
Content-Type: application/json

{
  "userId": "alice123",
  "name": "Alice Johnson"
}
```

### Create Event
```bash
POST /events
Content-Type: application/json

{
  "eventId": "conf2024",
  "name": "Tech Conference 2024",
  "capacity": 100,
  "hasWaitlist": true
}
```

### Register User for Event
```bash
POST /events/{eventId}/register
Content-Type: application/json

{
  "userId": "alice123"
}
```

### Unregister User from Event
```bash
DELETE /events/{eventId}/register/{userId}
```

### Get User's Registered Events
```bash
GET /users/{userId}/events
```

## Data Schemas

### User Schema

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| userId | string | Yes | Cannot be empty or whitespace-only |
| name | string | Yes | Cannot be empty or whitespace-only |

### Event Schema

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| eventId | string | Yes | Unique identifier |
| name | string | Yes | Event name |
| capacity | integer | Yes | Must be greater than 0 |
| hasWaitlist | boolean | Yes | Enable/disable waitlist |
| registered | array | Auto | List of registered user IDs |
| waitlist | array | Auto | List of waitlisted user IDs |

## Registration Workflow

1. **User Creation**: Create user profiles with unique IDs
2. **Event Creation**: Set up events with capacity and waitlist settings
3. **Registration**: Users register for events
   - If capacity available → added to registered list
   - If full with waitlist → added to waitlist
   - If full without waitlist → registration rejected
4. **Unregistration**: Users can unregister
   - If registered → removed and first waitlisted user promoted
   - If waitlisted → removed from waitlist
5. **Query Events**: Users can view their registered events (excludes waitlisted)

## Testing

Run the complete workflow validation test:
```bash
.\test_registration_workflow.ps1
```

## Documentation

API documentation is available in `backend/docs/` after running:
```bash
cd backend
pip install pdoc
pdoc main.py -o docs
```

## Project Structure

```
.
├── backend/              # FastAPI application
│   ├── main.py          # API endpoints and logic
│   └── requirements.txt # Python dependencies
├── backend_deploy/      # Lambda deployment package
├── infrastructure/      # AWS CDK infrastructure
│   ├── app.py          # CDK app entry point
│   ├── stack.py        # Stack definition
│   └── requirements.txt # CDK dependencies
├── test_api.ps1        # API validation tests
└── DEPLOYMENT.md       # Deployment details
```