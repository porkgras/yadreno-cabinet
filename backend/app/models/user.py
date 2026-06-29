from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class User(BaseModel):
    id: int
    telegram_id: str
    username: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    balance: float = 0.0
    is_admin: bool = False
    is_blocked: bool = False
    created_at: datetime
    updated_at: Optional[datetime] = None

class UserCreate(BaseModel):
    telegram_id: str
    username: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    telegram_id: str
    username: Optional[str] = None
    full_name: Optional[str] = None
    balance: float
    is_admin: bool
    keys_count: int = 0
    active_keys: int = 0
    referrals_count: int = 0
    created_at: datetime
