---
inclusion: fileMatch
fileMatchPattern: '(main|api|routes|endpoints|handlers)\.py'
---

# REST API Standards

## HTTP Methods

Use appropriate HTTP methods for operations:

- **GET**: Retrieve resources (read-only, idempotent)
- **POST**: Create new resources (non-idempotent)
- **PUT**: Update entire resources (idempotent)
- **PATCH**: Partial resource updates (idempotent)
- **DELETE**: Remove resources (idempotent)

## HTTP Status Codes

Return appropriate status codes:

### Success Codes
- **200 OK**: Successful GET, PUT, PATCH, or DELETE
- **201 Created**: Successful POST that creates a resource
- **204 No Content**: Successful DELETE with no response body

### Client Error Codes
- **400 Bad Request**: Invalid input, validation errors
- **401 Unauthorized**: Missing or invalid authentication
- **403 Forbidden**: Authenticated but not authorized
- **404 Not Found**: Resource doesn't exist
- **409 Conflict**: Resource conflict (e.g., duplicate)
- **422 Unprocessable Entity**: Semantic validation errors

### Server Error Codes
- **500 Internal Server Error**: Unexpected server errors
- **503 Service Unavailable**: Temporary unavailability

## Error Response Format

All error responses must follow this JSON structure:

```json
{
  "detail": "Human-readable error message",
  "error_code": "OPTIONAL_ERROR_CODE",
  "field_errors": [
    {
      "field": "field_name",
      "message": "Specific field error"
    }
  ]
}
```

For validation errors, include field-level details:

```json
{
  "detail": [
    {
      "type": "validation_error",
      "loc": ["body", "field_name"],
      "msg": "Field validation failed",
      "input": "invalid_value"
    }
  ]
}
```

## JSON Response Standards

### Consistency
- Use camelCase for JSON field names (or snake_case consistently)
- Always return JSON with `Content-Type: application/json`
- Include proper character encoding (UTF-8)

### Success Response Structure

**Single Resource:**
```json
{
  "id": "resource-id",
  "field1": "value1",
  "field2": "value2"
}
```

**Collection:**
```json
[
  {
    "id": "resource-1",
    "field1": "value1"
  },
  {
    "id": "resource-2",
    "field1": "value2"
  }
]
```

**With Pagination (optional):**
```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "page_size": 20
}
```

### Null Values
- Include fields with `null` values rather than omitting them
- Exception: Optional fields in partial updates (PATCH) can be omitted

### Timestamps
- Use ISO 8601 format: `"2024-12-15T10:30:00Z"`
- Always include timezone (prefer UTC)

## API Design Best Practices

### Endpoints
- Use plural nouns for collections: `/events`, `/users`
- Use resource IDs in path: `/events/{eventId}`
- Avoid verbs in URLs (use HTTP methods instead)

### Query Parameters
- Use for filtering: `?status=active`
- Use for sorting: `?sort=date&order=desc`
- Use for pagination: `?page=1&limit=20`

### Request/Response
- Validate all inputs before processing
- Return created resource in POST responses
- Return updated resource in PUT/PATCH responses
- Include meaningful error messages

### CORS
- Configure CORS headers for web access
- Allow appropriate origins, methods, and headers

### Idempotency
- GET, PUT, PATCH, DELETE must be idempotent
- POST should not be idempotent
- Consider idempotency keys for critical POST operations
