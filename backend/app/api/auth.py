from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from datetime import datetime, timedelta
from typing import Optional
import jwt
import os
from loguru import logger

router = APIRouter()
security = HTTPBearer()

class TelegramAuthData(BaseModel):
    id: int
    first_name: str
    last_name: Optional[str] = None
    username: Optional[str] = None
    photo_url: Optional[str] = None
    auth_date: int
    hash: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int

@router.post("/telegram", response_model=TokenResponse)
async def auth_telegram(request: Request):
    """Авторизация через Telegram Login Widget (упрощенная версия)"""
    try:
        data = await request.json()
        logger.info(f"Auth attempt from user: {data.get('id')} ({data.get('username')})")
        
        # Упрощенная проверка - пропускаем для теста
        # TODO: Добавить проверку hash
        
        # Создаем JWT токен
        token_data = {
            "sub": str(data.get('id', 123456789)),
            "username": data.get('username', 'user'),
            "first_name": data.get('first_name', 'User'),
            "exp": datetime.utcnow() + timedelta(minutes=30)
        }
        
        token = jwt.encode(
            token_data,
            os.getenv("JWT_SECRET_KEY", "secret"),
            algorithm="HS256"
        )
        
        return TokenResponse(
            access_token=token,
            expires_in=1800
        )
        
    except Exception as e:
        logger.error(f"Auth error: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/verify")
async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Проверка JWT токена"""
    token = credentials.credentials
    try:
        payload = jwt.decode(
            token,
            os.getenv("JWT_SECRET_KEY", "secret"),
            algorithms=["HS256"]
        )
        return {
            "valid": True,
            "user_id": payload.get("sub"),
            "username": payload.get("username")
        }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
