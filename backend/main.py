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
