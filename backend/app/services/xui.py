import httpx
from typing import Optional, Dict, List
from app.core.config import settings

class XUIClient:
    def __init__(self):
        self.base_url = settings.xui_host.rstrip('/')
        self.username = settings.xui_username
        self.password = settings.xui_password
        self.session = httpx.Client(timeout=30.0)
        self.cookies = None

    def login(self) -> bool:
        try:
            response = self.session.post(
                f"{self.base_url}/login",
                data={"username": self.username, "password": self.password}
            )
            if response.status_code == 200:
                self.cookies = response.cookies
                return True
            return False
        except Exception as e:
            print(f"Login error: {e}")
            return False

    def get_inbounds(self) -> Optional[List[Dict]]:
        if not self.login():
            return None
        try:
            response = self.session.get(
                f"{self.base_url}/panel/api/inbounds/list",
                cookies=self.cookies
            )
            if response.status_code == 200:
                data = response.json()
                return data.get('obj', [])
            return None
        except Exception as e:
            print(f"Get inbounds error: {e}")
            return None

    def get_inbound(self, inbound_id: int) -> Optional[Dict]:
        if not self.login():
            return None
        try:
            response = self.session.get(
                f"{self.base_url}/panel/api/inbounds/get/{inbound_id}",
                cookies=self.cookies
            )
            if response.status_code == 200:
                data = response.json()
                return data.get('obj')
            return None
        except Exception as e:
            print(f"Get inbound error: {e}")
            return None

    def create_client(self, inbound_id: int, email: str, password: str, total_gb: int) -> Optional[Dict]:
        """Создание клиента в 3x-ui"""
        if not self.login():
            return None
        try:
            client_data = {
                "id": inbound_id,
                "settings": {
                    "clients": [{
                        "email": email,
                        "password": password,
                        "total": total_gb * 1024**3,
                        "expiryTime": 0
                    }]
                }
            }
            response = self.session.post(
                f"{self.base_url}/panel/api/inbounds/addClient",
                json=client_data,
                cookies=self.cookies
            )
            if response.status_code == 200:
                return response.json()
            return None
        except Exception as e:
            print(f"Create client error: {e}")
            return None

xui_client = XUIClient()
