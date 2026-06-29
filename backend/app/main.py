"""
Yadreno Cabinet - Backend API
Веб-кабинет для управления VPN-ключами
"""

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from contextlib import asynccontextmanager
import os
from loguru import logger
from datetime import datetime
from dotenv import load_dotenv

from app.core.config import settings
from app.api import auth, users, keys, tariffs, payments, referrals

# Загрузка переменных окружения
load_dotenv()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Управление жизненным циклом приложения"""
    logger.info("🚀 Starting Yadreno Cabinet API v{}", settings.app_version)
    logger.info("📡 API Documentation available at /docs")
    yield
    logger.info("👋 Shutting down Yadreno Cabinet API...")

# Создание приложения
app = FastAPI(
    title=settings.app_name,
    description="API для веб-кабинета YadrenoVPN с интеграцией 3x-ui",
    version=settings.app_version,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключение роутеров
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(keys.router, prefix="/api/keys", tags=["keys"])
app.include_router(tariffs.router, prefix="/api/tariffs", tags=["tariffs"])
app.include_router(payments.router, prefix="/api/payments", tags=["payments"])
app.include_router(referrals.router, prefix="/api/referrals", tags=["referrals"])

# Root endpoint
@app.get("/")
async def root():
    return {
        "name": settings.app_name,
        "version": settings.app_version,
        "status": "running",
        "docs": "/docs",
        "timestamp": datetime.now().isoformat()
    }

# Health check
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": settings.app_version
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
