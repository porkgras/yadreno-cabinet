from fastapi import APIRouter, Depends, HTTPException
from typing import List
from loguru import logger

router = APIRouter()

@router.get("/me")
async def get_current_user():
    """
    Получение данных текущего пользователя
    """
    # TODO: Реализовать получение данных из бота
    return {
        "id": 1,
        "telegram_id": "123456789",
        "username": "test_user",
        "full_name": "Test User",
        "balance": 150.0,
        "is_admin": True,
        "keys_count": 3,
        "active_keys": 2,
        "referrals_count": 5,
        "created_at": "2026-01-01T00:00:00"
    }

@router.get("/me/keys")
async def get_user_keys():
    """
    Получение списка ключей пользователя
    """
    # TODO: Реализовать получение из 3x-ui
    return {
        "keys": [
            {
                "id": 1,
                "name": "Germany VPN",
                "server": "Germany",
                "protocol": "VLESS",
                "status": "active",
                "traffic_used": 10.5,
                "traffic_limit": 100.0,
                "traffic_percent": 10.5,
                "expire_date": "2026-12-31T23:59:59",
                "days_left": 30,
                "config_url": "vless://..."
            },
            {
                "id": 2,
                "name": "Netherlands VPN",
                "server": "Netherlands",
                "protocol": "VMess",
                "status": "active",
                "traffic_used": 45.2,
                "traffic_limit": 100.0,
                "traffic_percent": 45.2,
                "expire_date": "2026-11-15T23:59:59",
                "days_left": 15,
                "config_url": "vmess://..."
            }
        ]
    }

@router.get("/me/keys/{key_id}")
async def get_key_detail(key_id: int):
    """
    Получение детальной информации о ключе
    """
    # TODO: Реализовать получение деталей
    return {
        "id": key_id,
        "name": "Germany VPN",
        "server": "Germany",
        "server_ip": "123.123.123.123",
        "protocol": "VLESS",
        "port": 443,
        "status": "active",
        "traffic_used": 10.5,
        "traffic_limit": 100.0,
        "traffic_percent": 10.5,
        "expire_date": "2026-12-31T23:59:59",
        "created_at": "2026-01-01T00:00:00",
        "days_left": 30,
        "config_url": "vless://...",
        "subscription_url": "https://..."
    }

@router.get("/balance")
async def get_balance():
    """
    Получение баланса пользователя
    """
    return {
        "balance": 150.0,
        "currency": "⭐",
        "referral_earnings": 50.0
    }
