#!/bin/bash
# ============================================================
# 🚀 YADRENO CABINET - УСТАНОВЩИК
# Веб-кабинет для управления VPN
# ============================================================

set -e

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Очищаем экран
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

# Обновление пакетов
echo -e "${YELLOW}⏳ Обновление списка пакетов...${NC}"
apt update -qq 2>/dev/null
echo -e "${GREEN}✅ Список пакетов обновлен${NC}"

# Установка базовых пакетов
echo -e "${YELLOW}⏳ Установка базовых пакетов...${NC}"
apt install -y curl wget git ufw net-tools htop ca-certificates gnupg lsb-release 2>/dev/null
echo -e "${GREEN}✅ Базовые пакеты установлены${NC}"

# Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⏳ Установка Docker...${NC}"
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>/dev/null
    sh /tmp/get-docker.sh 2>/dev/null
    systemctl enable docker 2>/dev/null
    systemctl start docker 2>/dev/null
    echo -e "${GREEN}✅ Docker установлен${NC}"
else
    echo -e "${GREEN}✅ Docker уже установлен${NC}"
fi

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⏳ Установка Docker Compose...${NC}"
    apt install -y docker-compose-plugin 2>/dev/null
    echo -e "${GREEN}✅ Docker Compose установлен${NC}"
else
    echo -e "${GREEN}✅ Docker Compose уже установлен${NC}"
fi

# Проверка Docker
if ! docker ps &> /dev/null; then
    echo -e "${RED}❌ Docker не работает. Попробуйте перезагрузить сервер.${NC}"
    exit 1
fi
echo -e ""

# ============================================================
# ШАГ 3: НАСТРОЙКА БРАНДМАУЭРА
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}🛡️  ШАГ 3/7: НАСТРОЙКА БРАНДМАУЭРА${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
    echo -e "${YELLOW}⏳ Открываем порты...${NC}"
    ufw allow 22/tcp 2>/dev/null
    ufw allow 80/tcp 2>/dev/null
    ufw allow 443/tcp 2>/dev/null
    ufw allow 8000/tcp 2>/dev/null
    echo -e "${GREEN}✅ Порты открыты: 22 (SSH), 80 (HTTP), 443 (HTTPS), 8000 (API)${NC}"
else
    echo -e "${YELLOW}⚠️  Брандмауэр не активен. Пропускаем настройку.${NC}"
fi
echo -e ""

# ============================================================
# ШАГ 4: СБОР ДАННЫХ ПОЛЬЗОВАТЕЛЯ
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}📝 ШАГ 4/7: ВВЕДИТЕ ДАННЫЕ${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# ============================================================
# 4.1 ТОКЕН TELEGRAM БОТА
# ============================================================
echo -e "${BOLD}${CYAN}🤖 1. ТОКЕН TELEGRAM БОТА${NC}"
echo -e "${WHITE}   Как получить:${NC}"
echo -e "   ${WHITE}1. Откройте Telegram и найдите @BotFather${NC}"
echo -e "   ${WHITE}2. Отправьте команду: /newbot${NC}"
echo -e "   ${WHITE}3. Придумайте имя и username (заканчивается на 'bot')${NC}"
echo -e "   ${WHITE}4. Скопируйте полученный токен${NC}"
echo -e "   ${WHITE}Пример: 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz${NC}"
echo -e ""

while true; do
    echo -en "${GREEN}➜ Введите токен бота: ${NC}"
    read -r BOT_TOKEN
    if [[ "$BOT_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
        echo -e "${GREEN}✅ Токен принят${NC}"
        break
    else
        echo -e "${RED}❌ Неверный формат! Токен должен быть вида: 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz${NC}"
        echo -e ""
    fi
done
echo -e ""

# ============================================================
# 4.2 TELEGRAM ID АДМИНИСТРАТОРА
# ============================================================
echo -e "${BOLD}${CYAN}👤 2. ВАШ TELEGRAM ID${NC}"
echo -e "${WHITE}   Как получить:${NC}"
echo -e "   ${WHITE}1. Найдите в Telegram бота @userinfobot${NC}"
echo -e "   ${WHITE}2. Отправьте ему любое сообщение${NC}"
echo -e "   ${WHITE}3. Бот пришлет ваш ID (только цифры)${NC}"
echo -e "   ${WHITE}Пример: 123456789${NC}"
echo -e ""

while true; do
    echo -en "${GREEN}➜ Введите ваш Telegram ID: ${NC}"
    read -r ADMIN_IDS
    if [[ "$ADMIN_IDS" =~ ^[0-9]+$ ]]; then
        echo -e "${GREEN}✅ ID принят${NC}"
        break
    else
        echo -e "${RED}❌ ID должен содержать только цифры!${NC}"
        echo -e ""
    fi
done
echo -e ""

# ============================================================
# 4.3 3X-UI ПАНЕЛЬ
# ============================================================
echo -e "${BOLD}${CYAN}🖥️  3. ДАННЫЕ ПАНЕЛИ 3X-UI${NC}"
echo -e "${WHITE}   Введите данные для подключения к панели 3x-ui${NC}"
echo -e "   ${WHITE}Пример URL: https://bedalagavpn.mooo.com:44300${NC}"
echo -e ""

echo -en "${GREEN}➜ URL панели 3x-ui (Enter для значения по умолчанию): ${NC}"
read -r XUI_HOST
XUI_HOST=${XUI_HOST:-"https://bedalagavpn.mooo.com:44300"}
echo -e "${GREEN}✅ URL: $XUI_HOST${NC}"

echo -en "${GREEN}➜ Логин от панели 3x-ui (Enter для значения по умолчанию): ${NC}"
read -r XUI_USERNAME
XUI_USERNAME=${XUI_USERNAME:-"pavel"}
echo -e "${GREEN}✅ Логин: $XUI_USERNAME${NC}"

echo -en "${GREEN}➜ Пароль от панели 3x-ui (Enter для значения по умолчанию): ${NC}"
read -r XUI_PASSWORD
XUI_PASSWORD=${XUI_PASSWORD:-"pavel"}
echo -e "${GREEN}✅ Пароль установлен${NC}"
echo -e ""

# ============================================================
# 4.4 ДОМЕН ИЛИ IP
# ============================================================
echo -e "${BOLD}${CYAN}🌐 4. ДОМЕН ИЛИ IP-АДРЕС${NC}"
echo -e "${WHITE}   Вы можете использовать домен или IP-адрес сервера${NC}"
echo -e "   ${WHITE}Если у вас есть домен - введите его${NC}"
echo -e "   ${WHITE}Если домена нет - будет использован IP-адрес${NC}"
echo -e ""

# Получаем IP-адрес сервера
SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "localhost")

echo -en "${GREEN}➜ Введите домен (или нажмите Enter для IP $SERVER_IP): ${NC}"
read -r DOMAIN
DOMAIN=${DOMAIN:-$SERVER_IP}
echo -e "${GREEN}✅ Используется: $DOMAIN${NC}"
echo -e ""

# ============================================================
# 4.5 SSL СЕРТИФИКАТ
# ============================================================
echo -e "${BOLD}${CYAN}🔒 5. НАСТРОЙКА SSL/HTTPS${NC}"
echo -e "${WHITE}   SSL обеспечивает безопасное соединение через HTTPS${NC}"
echo -e "   ${WHITE}Рекомендуется для доменов${NC}"
echo -e "   ${WHITE}Для IP-адресов SSL не работает${NC}"
echo -e ""

# Проверяем, является ли введенное значение IP-адресом
if [[ "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${YELLOW}⚠️  Обнаружен IP-адрес. SSL для IP не поддерживается.${NC}"
    SSL_SETUP="n"
    echo -e "${YELLOW}💡 Рекомендуем использовать домен для HTTPS${NC}"
else
    echo -en "${GREEN}➜ Настроить SSL? (y/n): ${NC}"
    read -r SSL_SETUP
fi
echo -e ""

# ============================================================
# 4.6 ПОДТВЕРЖДЕНИЕ ДАННЫХ
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}📋 ПРОВЕРЬТЕ ВВЕДЕННЫЕ ДАННЫЕ${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "${GREEN}🤖 Токен бота:${NC} $BOT_TOKEN"
echo -e "${GREEN}👤 Telegram ID:${NC} $ADMIN_IDS"
echo -e "${GREEN}🖥️  Панель 3x-ui:${NC} $XUI_HOST"
echo -e "${GREEN}👤 Логин 3x-ui:${NC} $XUI_USERNAME"
echo -e "${GREEN}🌐 Домен/IP:${NC} $DOMAIN"
if [[ "$SSL_SETUP" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🔒 SSL:${NC} Да"
else
    echo -e "${GREEN}🔒 SSL:${NC} Нет"
fi
echo -e ""

echo -en "${YELLOW}⚠️  Все верно? Продолжить установку? (y/N): ${NC}"
read -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🔄 Перезапустите скрипт для повторного ввода данных.${NC}"
    exit 0
fi
echo -e ""

# ============================================================
# ШАГ 5: СОЗДАНИЕ .ENV ФАЙЛА
# ============================================================
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${WHITE}📝 ШАГ 5/7: СОЗДАНИЕ КОНФИГУРАЦИИ${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

echo -e "${YELLOW}⏳ Генерация секретных ключей...${NC}"
JWT_SECRET=$(openssl rand -hex 32)
SECRET_KEY=$(openssl rand -hex 32)

echo -e "${YELLOW}⏳ Создание .env файла...${NC}"
cat > .env << EOF
# ============================================================
# YADRENO CABINET - КОНФИГУРАЦИЯ
# ============================================================
# Документация: https://github.com/porkgras/yadreno-cabinet
# Дата создания: $(date +'%Y-%m-%d %H:%M:%S')
# ============================================================

# ---------- TELEGRAM БОТ ----------
BOT_TOKEN=$BOT_TOKEN
ADMIN_IDS=$ADMIN_IDS

# ---------- ПАНЕЛЬ 3X-UI ----------
XUI_HOST=$XUI_HOST
XUI_USERNAME=$XUI_USERNAME
XUI_PASSWORD=$XUI_PASSWORD

# ---------- JWT БЕЗОПАСНОСТЬ ----------
JWT_SECRET_KEY=$JWT_SECRET
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# ---------- БАЗА ДАННЫХ ----------
DB_TYPE=sqlite
DB_PATH=/app/data/app.db

# ---------- ДОСТУП К API ----------
ALLOWED_ORIGINS=https://$DOMAIN,http://$DOMAIN,http://localhost:3000

# ---------- НАСТРОЙКИ ПРИЛОЖЕНИЯ ----------
APP_NAME=Yadreno Cabinet
APP_DEBUG=false
APP_VERSION=1.0.0
SECRET_KEY=$SECRET_KEY

# ---------- РЕДИС (ОПЦИОНАЛЬНО) ----------
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# ---------- ЛОГИРОВАНИЕ ----------
LOG_LEVEL=info
LOG_FILE=/app/logs/app.log
