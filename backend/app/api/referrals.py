from fastapi import APIRouter

router = APIRouter()

@router.get("/info")
async def get_referral_info():
    """
    Информация о реферальной системе
    """
    return {
        "enabled": True,
        "referral_link": "https://t.me/your_bot?start=ref_123",
        "levels": [
            {"level": 1, "percent": 10, "enabled": True},
            {"level": 2, "percent": 5, "enabled": True},
            {"level": 3, "percent": 2, "enabled": False}
        ],
        "earnings": 50.0,
        "currency": "⭐",
        "referrals": [
            {
                "id": 1,
                "username": "user1",
                "joined_at": "2026-01-01T00:00:00",
                "level": 1,
                "earnings": 20.0
            },
            {
                "id": 2,
                "username": "user2",
                "joined_at": "2026-01-05T00:00:00",
                "level": 2,
                "earnings": 10.0
            }
        ],
        "total_referrals": 5
    }
