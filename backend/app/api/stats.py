from fastapi import APIRouter, Depends, HTTPException
from typing import List, Optional
from datetime import datetime, timedelta
from loguru import logger

router = APIRouter(prefix="/api/stats", tags=["stats"])

# Временное хранилище данных (позже заменим на БД)
stats_data = {
    "total_users": 0,
    "total_keys": 0,
    "active_keys": 0,
    "total_referrals": 0,
    "today_new_users": 0,
    "today_new_keys": 0,
    "last_updated": datetime.utcnow().isoformat()
}

@router.get("/")
async def get_stats():
    """Получить статистику"""
    return {
        "total_users": stats_data["total_users"],
        "total_keys": stats_data["total_keys"],
        "active_keys": stats_data["active_keys"],
        "total_referrals": stats_data["total_referrals"],
        "today_new_users": stats_data["today_new_users"],
        "today_new_keys": stats_data["today_new_keys"],
        "last_updated": stats_data["last_updated"]
    }

@router.post("/update")
async def update_stats(data: dict):
    """Обновить статистику (для внутреннего использования)"""
    for key in ["total_users", "total_keys", "active_keys", "total_referrals", "today_new_users", "today_new_keys"]:
        if key in data:
            stats_data[key] = data[key]
    stats_data["last_updated"] = datetime.utcnow().isoformat()
    return {"status": "updated"}
