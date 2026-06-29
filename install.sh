#!/bin/bash
# ============================================================
# 🚀 Yadreno Cabinet - Professional Installer
# ============================================================

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Баннер
echo -e "${BLUE}"
cat << "BANNER"
╔═══════════════════════════════════════════╗
║     🚀 YADRENO CABINET INSTALLER         ║
║     Веб-кабинет для управления VPN       ║
╚═══════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# Проверка прав
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Запустите с правами root: sudo bash install.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}🔍 Проверка системы...${NC}"

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Установка Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
fi

# Проверка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Установка Docker Compose...${NC}"
    apt update
    apt install docker-compose-plugin -y
fi

# Запрос данных
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Введите необходимые данные:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Функция для ввода
get_input() {
    local prompt="$1"
    local default="$2"
    local value
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " value
        echo "${value:-$default}"
    else
        read -p "$prompt: " value
        echo "$value"
    fi
}

BOT_TOKEN=$(get_input "🤖 Токен бота (от @BotFather)" "")
ADMIN_IDS=$(get_input "👤 Ваш Telegram ID (от @userinfobot)" "")
XUI_HOST=$(get_input "🖥️  URL панели 3x-ui" "https://bedalagavpn.mooo.com:44300")
XUI_USERNAME=$(get_input "👤 Логин 3x-ui" "pavel")
XUI_PASSWORD=$(get_input "🔑 Пароль 3x-ui" "pavel")
DOMAIN=$(get_input "🌐 Домен" "miniapp.bedalagavpn.mooo.com")

# Генерация ключей
JWT_SECRET=$(openssl rand -hex 32)
SECRET_KEY=$(openssl rand -hex 32)

# Создание .env
echo -e "\n${YELLOW}📝 Создание .env...${NC}"
cat > .env << EOF
BOT_TOKEN=$BOT_TOKEN
ADMIN_IDS=$ADMIN_IDS
XUI_HOST=$XUI_HOST
XUI_USERNAME=$XUI_USERNAME
XUI_PASSWORD=$XUI_PASSWORD
JWT_SECRET_KEY=$JWT_SECRET
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
DB_TYPE=sqlite
DB_PATH=/app/data/app.db
ALLOWED_ORIGINS=https://$DOMAIN,http://$DOMAIN,http://localhost:3000
APP_NAME=Yadreno Cabinet
APP_DEBUG=false
APP_VERSION=1.0.0
SECRET_KEY=$SECRET_KEY
