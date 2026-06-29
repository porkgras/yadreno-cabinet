from pydantic import BaseModel
from typing import Optional

class Tariff(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    price: float
    currency: str = "⭐"
    traffic_limit: float  # GB
    period_days: int
    max_devices: int = 1
    is_active: bool = True
    group_id: Optional[int] = None

class TariffResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    price: float
    currency: str
    traffic_limit: float
    period_days: int
    max_devices: int
    is_active: bool
    price_formatted: str
