from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from item_router import router as item_router
from dbutils import Base, engine

app = FastAPI(
    title="FastAPI Async API",
    description="A FastAPI Async application with CRUD operations",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(item_router)

# Create tables asynchronously
async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

@app.on_event("startup")
async def startup_event():
    await init_db()

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI Async API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)