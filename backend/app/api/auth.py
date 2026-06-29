from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from datetime import datetime, timedelta
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
async def auth_telegram(data: TelegramAuthData):
    """
    Авторизация через Telegram Login Widget
    """
    # TODO: Реализовать проверку hash
    # Временная реализация
    logger.info(f"User {data.id} ({data.username}) logged in")
    
    # Создаем JWT токен
    token_data = {
        "sub": str(data.id),
        "username": data.username,
        "first_name": data.first_name,
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

@router.get("/verify")
async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Проверка JWT токена
    """
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
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired"
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
