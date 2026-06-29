#!/bin/bash
# ============================================================
# 🚀 YADRENO CABINET - УСТАНОВЩИК
# ============================================================

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

clear

# ============================================================
# БАННЕР
# ============================================================
echo -e "${BLUE}"
cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     🚀 YADRENO CABINET - ПРОФЕССИОНАЛЬНЫЙ УСТАНОВЩИК       ║
║                                                              ║
║     Веб-кабинет для управления VPN-ключами                  ║
║     Установка за 5 минут!                                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

echo -e "${CYAN}📋 Документация: https://github.com/porkgras/yadreno-cabinet${NC}"
echo -e "${CYAN}💬 Поддержка: https://t.me/porkgras${NC}"
echo -e ""

# ============================================================
# ШАГ 1: ПРОВЕРКА СИСТЕМЫ
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}🔍 ШАГ 1/7: ПРОВЕРКА СИСТЕМЫ${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Ошибка: Скрипт должен запускаться с правами root${NC}"
    echo -e "${YELLOW}💡 Используйте: sudo bash install.sh${NC}"
    exit 1
fi

# Проверка ОС
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}❌ Ошибка: Скрипт работает только на Ubuntu${NC}"
    echo -e "${YELLOW}💡 Текущая ОС: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Система: $(lsb_release -ds)${NC}"
echo -e "${GREEN}✅ Архитектура: $(uname -m)${NC}"
echo -e "${GREEN}✅ RAM: $(free -h | grep Mem | awk '{print $2}')${NC}"
echo -e "${GREEN}✅ Свободно места: $(df -h / | awk 'NR==2 {print $4}')${NC}"
echo -e ""

# ============================================================
# ШАГ 2: УСТАНОВКА ЗАВИСИМОСТЕЙ
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}📦 ШАГ 2/7: УСТАНОВКА ЗАВИСИМОСТЕЙ${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

echo -e "${YELLOW}⏳ Обновление пакетов...${NC}"
apt update -qq 2>/dev/null

echo -e "${YELLOW}⏳ Установка базовых пакетов...${NC}"
apt install -y -qq curl wget git docker.io docker-compose-plugin ufw 2>/dev/null

echo -e "${GREEN}✅ Все зависимости установлены${NC}"
echo -e ""

# ============================================================
# ШАГ 3: НАСТРОЙКА FIREWALL
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}🛡️  ШАГ 3/7: НАСТРОЙКА FIREWALL${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

ufw allow 22/tcp >/dev/null 2>&1
ufw allow 80/tcp >/dev/null 2>&1
ufw allow 443/tcp >/dev/null 2>&1
ufw allow 8000/tcp >/dev/null 2>&1
ufw --force enable >/dev/null 2>&1

echo -e "${GREEN}✅ Firewall настроен (открыты порты: 22, 80, 443, 8000)${NC}"
echo -e ""

# ============================================================
# ШАГ 4: СБОР ДАННЫХ
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}📝 ШАГ 4/7: ВВЕДИТЕ ДАННЫЕ ДЛЯ НАСТРОЙКИ${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

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

echo -e "${GREEN}✅ Данные сохранены${NC}"
echo -e ""

# ============================================================
# ШАГ 5: СОЗДАНИЕ .env
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}📄 ШАГ 5/7: СОЗДАНИЕ .env ФАЙЛА${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

cat > .env << EOF
# YADRENO CABINET CONFIGURATION
BOT_TOKEN=$BOT_TOKEN
ADMIN_IDS=$ADMIN_IDS
XUI_HOST=$XUI_HOST
XUI_USERNAME=$XUI_USERNAME
XUI_PASSWORD=$XUI_PASSWORD
JWT_SECRET_KEY=$JWT_SECRET
SECRET_KEY=$SECRET_KEY
ALLOWED_ORIGINS=http://localhost:3000,https://$DOMAIN
APP_NAME=Yadreno Cabinet
APP_DEBUG=false
EOF

echo -e "${GREEN}✅ .env файл создан${NC}"
echo -e ""

# ============================================================
# ШАГ 6: ЗАПУСК ПРОЕКТА
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}🚀 ШАГ 6/7: ЗАПУСК ПРОЕКТА${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

echo -e "${YELLOW}⏳ Запуск контейнеров...${NC}"
docker compose up -d --build >/dev/null 2>&1

echo -e "${GREEN}✅ Контейнеры запущены${NC}"
echo -e ""

# ============================================================
# ШАГ 7: НАСТРОЙКА SSL
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}🔒 ШАГ 7/7: НАСТРОЙКА SSL${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

echo -e "${YELLOW}⏳ Установка Certbot...${NC}"
apt install -y -qq certbot 2>/dev/null

echo -e "${YELLOW}⏳ Получение SSL сертификата для $DOMAIN...${NC}"
docker compose stop nginx >/dev/null 2>&1
certbot certonly --standalone -d "$DOMAIN" --non-interactive --agree-tos --email porogras@mail.ru >/dev/null 2>&1
docker compose start nginx >/dev/null 2>&1

if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo -e "${GREEN}✅ SSL сертификат получен и настроен${NC}"
else
    echo -e "${YELLOW}⚠️  SSL сертификат не получен. Проверьте домен и запустите позже:${NC}"
    echo -e "   certbot certonly --standalone -d $DOMAIN"
fi
echo -e ""

# ============================================================
# ФИНАЛЬНЫЙ ЭКРАН
# ============================================================
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${GREEN}🎉 УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА${NC}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "${BOLD}🌐 ДОСТУП К КАБИНЕТУ:${NC}"
echo -e "   ➜ HTTP:  http://$DOMAIN"
echo -e "   ➜ HTTPS: https://$DOMAIN"
echo -e ""
echo -e "${BOLD}📚 ДОКУМЕНТАЦИЯ API:${NC}"
echo -e "   ➜ Swagger: https://$DOMAIN/docs"
echo -e "   ➜ ReDoc:   https://$DOMAIN/redoc"
echo -e ""
echo -e "${BOLD}🖥️  ПАНЕЛЬ 3X-UI:${NC}"
echo -e "   ➜ URL:     $XUI_HOST"
echo -e "   ➜ Логин:   $XUI_USERNAME"
echo -e "   ➜ Пароль:  $XUI_PASSWORD"
echo -e ""
echo -e "${BOLD}💡 ПОЛЕЗНЫЕ КОМАНДЫ:${NC}"
echo -e "   ➜ docker compose ps        - статус контейнеров"
echo -e "   ➜ docker compose logs -f   - логи в реальном времени"
echo -e "   ➜ docker compose restart   - перезапуск"
echo -e "   ➜ docker compose down      - остановка"
echo -e ""
echo -e "${BOLD}📂 ВАЖНЫЕ ФАЙЛЫ:${NC}"
echo -e "   ➜ .env           - конфигурация ($PWD/.env)"
echo -e "   ➜ data/          - база данных ($PWD/data)"
echo -e ""
echo -e "${BOLD}🔧 ПОДДЕРЖКА:${NC}"
echo -e "   ➜ GitHub:  https://github.com/porkgras/yadreno-cabinet"
echo -e "   ➜ Issues:  https://github.com/porkgras/yadreno-cabinet/issues"
echo -e ""
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${GREEN}🚀 Спасибо за использование Yadreno Cabinet!${NC}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
