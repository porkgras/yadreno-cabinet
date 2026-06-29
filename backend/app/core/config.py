"""
Настройки приложения
"""
import os
from typing import List, Optional
from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    """Настройки приложения"""
    
    # App
    app_name: str = Field(default="Yadreno Cabinet", env="APP_NAME")
    app_debug: bool = Field(default=False, env="APP_DEBUG")
    app_version: str = Field(default="1.0.0", env="APP_VERSION")
    secret_key: str = Field(..., env="SECRET_KEY")
    
    # JWT
    jwt_secret_key: str = Field(..., env="JWT_SECRET_KEY")
    jwt_algorithm: str = Field(default="HS256", env="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(default=30, env="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(default=7, env="REFRESH_TOKEN_EXPIRE_DAYS")
    
    # Bot
    bot_token: str = Field(..., env="BOT_TOKEN")
    admin_ids: List[int] = Field(default=[], env="ADMIN_IDS")
    
    # 3x-ui
    xui_host: str = Field(..., env="XUI_HOST")
    xui_username: str = Field(..., env="XUI_USERNAME")
    xui_password: str = Field(..., env="XUI_PASSWORD")
    
    # Database
    db_type: str = Field(default="sqlite", env="DB_TYPE")
    db_path: str = Field(default="/app/data/app.db", env="DB_PATH")
    
    # CORS
    allowed_origins: List[str] = Field(
        default=["http://localhost:3000", "http://localhost:5173"],
        env="ALLOWED_ORIGINS"
    )
    
    # Redis
    redis_host: str = Field(default="localhost", env="REDIS_HOST")
    redis_port: int = Field(default=6379, env="REDIS_PORT")
    redis_password: Optional[str] = Field(default=None, env="REDIS_PASSWORD")
    redis_db: int = Field(default=0, env="REDIS_DB")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False

settings = Settings()
