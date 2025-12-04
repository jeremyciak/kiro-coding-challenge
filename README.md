# Events API

A serverless REST API for managing events, built with FastAPI and deployed on AWS using Lambda and API Gateway.

## Architecture

- **Backend**: FastAPI with Python 3.11
- **Database**: DynamoDB
- **Infrastructure**: AWS CDK (Python)
- **Deployment**: API Gateway + Lambda (serverless)

## Features

- Full CRUD operations for events
- Query filtering by status
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

### Create Event
```bash
POST /events
Content-Type: application/json

{
  "title": "Tech Conference",
  "description": "Annual tech conference",
  "date": "2024-12-15",
  "location": "San Francisco",
  "capacity": 500,
  "organizer": "Tech Corp",
  "status": "active"
}
```

### List Events
```bash
GET /events
GET /events?status=active
```

### Get Event
```bash
GET /events/{eventId}
```

### Update Event
```bash
PUT /events/{eventId}
Content-Type: application/json

{
  "title": "Updated Title",
  "capacity": 600
}
```

### Delete Event
```bash
DELETE /events/{eventId}
```

## Event Schema

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| eventId | string | No (auto-generated) | - |
| title | string | Yes | 1-200 characters |
| description | string | Yes | 1-1000 characters |
| date | string | Yes | YYYY-MM-DD format |
| location | string | Yes | 1-200 characters |
| capacity | integer | Yes | Greater than 0 |
| organizer | string | Yes | 1-200 characters |
| status | string | Yes | active, inactive, cancelled, or completed |

## Testing

Run the validation test script:
```bash
.\test_api.ps1
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