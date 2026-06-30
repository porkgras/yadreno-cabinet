"""
Настройки приложения
"""
import os
from typing import List, Optional

class Settings:
    """Настройки приложения"""
    
    # App
    app_name: str = os.getenv("APP_NAME", "Yadreno Cabinet")
    app_debug: bool = os.getenv("APP_DEBUG", "false").lower() == "true"
    app_version: str = os.getenv("APP_VERSION", "1.0.0")
    secret_key: str = os.getenv("SECRET_KEY", "secret")
    
    # JWT
    jwt_secret_key: str = os.getenv("JWT_SECRET_KEY", "secret")
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    access_token_expire_minutes: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    refresh_token_expire_days: int = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "7"))
    
    # Bot
    bot_token: str = os.getenv("BOT_TOKEN", "")
    admin_ids: List[int] = [int(x.strip()) for x in os.getenv("ADMIN_IDS", "").split(",") if x.strip()]
    
    # 3x-ui
    xui_host: str = os.getenv("XUI_HOST", "https://panel.bedalagavpn.xyz:2053")
    xui_username: str = os.getenv("XUI_USERNAME", "pavel")
    xui_password: str = os.getenv("XUI_PASSWORD", "pavel")
    
    # Database
    db_type: str = os.getenv("DB_TYPE", "sqlite")
    db_path: str = os.getenv("DB_PATH", "/app/data/app.db")
    
    # CORS
    allowed_origins: List[str] = [x.strip() for x in os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,https://miniapp.bedalagavpn.mooo.com").split(",") if x.strip()]
    
    # Redis
    redis_host: str = os.getenv("REDIS_HOST", "localhost")
    redis_port: int = int(os.getenv("REDIS_PORT", "6379"))
    redis_password: Optional[str] = os.getenv("REDIS_PASSWORD")
    redis_db: int = int(os.getenv("REDIS_DB", "0"))

settings = Settings()
