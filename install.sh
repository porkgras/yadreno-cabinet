#!/bin/bash
# ============================================
# Yadreno Cabinet Installer
# Веб-кабинет для YadrenoVPN + 3x-ui
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo -e "${BLUE}"
cat << "BANNER"
╔═══════════════════════════════════════════╗
║     🚀 YADRENO CABINET INSTALLER         ║
║     Веб-кабинет для VPN                   ║
╚═══════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# Проверка прав
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Пожалуйста, запустите скрипт с правами root: sudo bash install.sh${NC}"
    exit 1
fi

# Проверка системы
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

# Создание .env файла
if [ ! -f .env ]; then
    echo -e "${YELLOW}📝 Создание .env файла...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Отредактируйте .env файл перед запуском:${NC}"
    echo -e "   ${GREEN}nano .env${NC}"
    echo -e ""
    echo -e "${YELLOW}Необходимо указать:${NC}"
    echo -e "   - BOT_TOKEN (токен Telegram бота)"
    echo -e "   - ADMIN_IDS (ваш Telegram ID)"
    echo -e "   - XUI_HOST, XUI_USERNAME, XUI_PASSWORD (данные 3x-ui)"
    echo -e "   - JWT_SECRET_KEY (сгенерируйте случайную строку)"
    echo -e "   - SECRET_KEY (сгенерируйте случайную строку)"
    echo -e ""
    echo -e "${YELLOW}Затем запустите:${NC}"
    echo -e "   ${GREEN}docker-compose up -d --build${NC}"
    exit 0
fi

# Создание папки для данных
mkdir -p data

# Запуск
echo -e "${GREEN}🚀 Запуск Yadreno Cabinet...${NC}"
docker-compose down 2>/dev/null || true
docker-compose up -d --build

# Проверка статуса
sleep 5
if docker ps | grep -q yadreno; then
    echo -e "${GREEN}✅ Yadreno Cabinet успешно установлен!${NC}"
    echo -e "${GREEN}🌐 Откройте браузер: http://$(curl -s ifconfig.me)${NC}"
    echo -e "${GREEN}📚 Документация API: http://$(curl -s ifconfig.me)/docs${NC}"
else
    echo -e "${RED}❌ Ошибка при запуске. Проверьте логи: docker-compose logs${NC}"
fi
