from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum

class KeyStatus(str, Enum):
    active = "active"
    expired = "expired"
    blocked = "blocked"
    pending = "pending"

class Key(BaseModel):
    id: int
    user_id: int
    name: str
    server: str
    protocol: str
    status: KeyStatus
    traffic_used: float = 0.0
    traffic_limit: float = 0.0
    expire_date: datetime
    created_at: datetime
    updated_at: Optional[datetime] = None

class KeyResponse(BaseModel):
    id: int
    name: str
    server: str
    protocol: str
    status: str
    traffic_used: float
    traffic_limit: float
    traffic_percent: float
    expire_date: datetime
    days_left: int
    config_url: Optional[str] = None
