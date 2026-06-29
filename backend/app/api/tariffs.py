from fastapi import APIRouter
from typing import List

router = APIRouter()

@router.get("/")
async def get_tariffs():
    """
    Получение списка тарифов
    """
    # TODO: Реализовать получение из бота
    return {
        "tariffs": [
            {
                "id": 1,
                "name": "Light",
                "description": "Для обычного серфинга",
                "price": 100.0,
                "currency": "⭐",
                "traffic_limit": 30.0,
                "period_days": 30,
                "max_devices": 1,
                "is_active": True,
                "price_formatted": "100 ⭐"
            },
            {
                "id": 2,
                "name": "Standard",
                "description": "Для потокового видео",
                "price": 200.0,
                "currency": "⭐",
                "traffic_limit": 100.0,
                "period_days": 30,
                "max_devices": 3,
                "is_active": True,
                "price_formatted": "200 ⭐"
            },
            {
                "id": 3,
                "name": "Premium",
                "description": "Максимальная скорость",
                "price": 500.0,
                "currency": "⭐",
                "traffic_limit": 0.0,
                "period_days": 30,
                "max_devices": 5,
                "is_active": True,
                "price_formatted": "500 ⭐"
            }
        ]
    }

@router.get("/{tariff_id}")
async def get_tariff(tariff_id: int):
    """
    Получение информации о конкретном тарифе
    """
    # TODO: Реализовать получение из бота
    return {
        "id": tariff_id,
        "name": "Standard",
        "description": "Для потокового видео",
        "price": 200.0,
        "currency": "⭐",
        "traffic_limit": 100.0,
        "period_days": 30,
        "max_devices": 3,
        "is_active": True,
        "price_formatted": "200 ⭐"
    }
