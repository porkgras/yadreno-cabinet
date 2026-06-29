#!/bin/bash
# ============================================================
# 🚀 Yadreno Cabinet - Professional Installer v2.0
# Веб-кабинет для управления VPN (YadrenoVPN + 3x-ui)
# ============================================================
# Автор: porkgras
# Лицензия: MIT
# GitHub: https://github.com/porkgras/yadreno-cabinet
# ============================================================

set -e

# ============================================================
# ПЕРЕМЕННЫЕ И НАСТРОЙКИ
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/yadreno-install-$(date +%Y%m%d_%H%M%S).log"
INSTALL_DIR="/root/yadreno-cabinet"
BACKUP_DIR="/root/backups/yadreno-cabinet"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# ============================================================
# ФУНКЦИИ
# ============================================================

# Функция логирования
log() {
    echo -e "${2:-$WHITE}[$(date +'%H:%M:%S')]${NC} $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Функция для вопросов
ask() {
    local prompt="$1"
    local default="$2"
    local color="${3:-$CYAN}"
    
    if [ -n "$default" ]; then
        echo -e "${color}❓ $prompt ${DIM}[$default]${NC}: "
        read -r answer
        echo "${answer:-$default}"
    else
        echo -e "${color}❓ $prompt${NC}: "
        read -r answer
        echo "$answer"
    fi
}

# Функция для подтверждения
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    local answer
    
    echo -e "${YELLOW}⚠️  $prompt${NC}"
    read -r -p "Продолжить? (y/N): " answer
    answer=${answer:-$default}
    [[ "$answer" =~ ^[Yy]$ ]]
}

# Функция проверки команды
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Функция проверки порта
port_is_open() {
    local port=$1
    ! ss -tuln | grep -q ":$port "
}

# Функция генерации случайной строки
generate_secret() {
    openssl rand -hex 32 2>/dev/null || echo "secret-$(date +%s)"
}

# Функция проверки статуса
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        log "ERROR: $2"
        if [ -n "$3" ]; then
            echo -e "${YELLOW}💡 $3${NC}"
        fi
        return 1
    fi
}

# Функция отображения прогресса
show_progress() {
    local message="$1"
    echo -ne "${BLUE}⏳ $message...${NC}\r"
}

# Функция завершения с ошибкой
error_exit() {
    echo -e "\n${RED}❌ ОШИБКА: $1${NC}"
    echo -e "${YELLOW}📝 Лог сохранен: $LOG_FILE${NC}"
    echo -e "${YELLOW}💡 Попробуйте запустить снова или обратитесь к документации.${NC}"
    exit 1
}

# Функция очистки при ошибке
cleanup_on_error() {
    echo -e "\n${YELLOW}🧹 Выполняю очистку...${NC}"
    docker-compose down 2>/dev/null || true
}

# ============================================================
# БАННЕР
# ============================================================

show_banner() {
    clear
    echo -e "${BLUE}"
    cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     ██╗   ██╗ █████╗ ██████╗ ██████╗ ███████╗███╗   ██╗ ██████╗ 
║     ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔═══██╗
║      ╚████╔╝ ███████║██████╔╝██████╔╝█████╗  ██╔██╗ ██║██║   ██║
║       ╚██╔╝  ██╔══██║██╔══██╗██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║
║        ██║   ██║  ██║██║  ██║██████╔╝███████╗██║ ╚████║╚██████╔╝
║        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
║                                                              ║
║                   ██████╗  █████╗ ██████╗ ██╗███╗   ██╗███████╗████████╗
║                   ██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝╚══██╔══╝
║                   ██████╔╝███████║██████╔╝██║██╔██╗ ██║█████╗     ██║   
║                   ██╔══██╗██╔══██║██╔══██╗██║██║╚██╗██║██╔══╝     ██║   
║                   ██████╔╝██║  ██║██████╔╝██║██║ ╚████║███████╗   ██║   
║                   ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   
║                                                              ║
║         Professional Web Cabinet for VPN Management          ║
║         Version 2.0 | One-Command Installation               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    
    echo -e "${DIM}📋 Документация: https://github.com/porkgras/yadreno-cabinet${NC}"
    echo -e "${DIM}📝 Лог установки: $LOG_FILE${NC}"
    echo -e ""
}

# ============================================================
# ПРОВЕРКА СИСТЕМЫ
# ============================================================

check_system() {
    log "Проверка системы..." "$YELLOW"
    
    # Проверка прав root
    if [ "$EUID" -ne 0 ]; then
        error_exit "Скрипт должен запускаться с правами root.\n${YELLOW}Используйте: sudo bash install.sh${NC}"
    fi
    
    # Проверка ОС
    if ! grep -q "Ubuntu" /etc/os-release; then
        error_exit "Скрипт поддерживает только Ubuntu.\n${YELLOW}Текущая ОС: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)${NC}"
    fi
    
    OS_VERSION=$(lsb_release -rs)
    log "✅ ОС: Ubuntu $OS_VERSION" "$GREEN"
    
    # Проверка архитектуры
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
        error_exit "Поддерживаются только x86_64 и aarch64 архитектуры. Текущая: $ARCH"
    fi
    log "✅ Архитектура: $ARCH" "$GREEN"
    
    # Проверка свободного места
    FREE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$FREE_SPACE" -lt 10 ]; then
        log "⚠️  Мало свободного места: ${FREE_SPACE}GB (рекомендуется 10GB+)" "$YELLOW"
        if ! confirm "Продолжить с малым объемом места?"; then
            error_exit "Установка отменена пользователем"
        fi
    fi
    log "✅ Свободно: ${FREE_SPACE}GB" "$GREEN"
    
    # Проверка памяти
    TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_MEM" -lt 1 ]; then
        log "⚠️  Мало RAM: ${TOTAL_MEM}GB (рекомендуется 2GB+)" "$YELLOW"
    fi
    log "✅ RAM: ${TOTAL_MEM}GB" "$GREEN"
    
    echo ""
}

# ============================================================
# УСТАНОВКА ЗАВИСИМОСТЕЙ
# ============================================================

install_dependencies() {
    log "Установка зависимостей..." "$YELLOW"
    
    # Обновление пакетов
    show_progress "Обновление списка пакетов"
    apt update -qq 2>&1 | tee -a "$LOG_FILE" > /dev/null
    check_status "Список пакетов обновлен" "Ошибка обновления пакетов"
    
    # Установка базовых пакетов
    show_progress "Установка базовых пакетов"
    apt install -y curl wget git ufw net-tools htop \
        ca-certificates gnupg lsb-release 2>&1 | tee -a "$LOG_FILE" > /dev/null
    check_status "Базовые пакеты установлены" "Ошибка установки базовых пакетов"
    
    # Установка Docker
    if ! command_exists docker; then
        log "Установка Docker..." "$YELLOW"
        show_progress "Загрузка Docker"
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>&1 | tee -a "$LOG_FILE"
        check_status "Docker загружен" "Ошибка загрузки Docker"
        
        show_progress "Установка Docker"
        sh /tmp/get-docker.sh 2>&1 | tee -a "$LOG_FILE" > /dev/null
        check_status "Docker установлен" "Ошибка установки Docker"
        
        systemctl enable docker 2>&1 | tee -a "$LOG_FILE"
        systemctl start docker 2>&1 | tee -a "$LOG_FILE"
        check_status "Docker запущен" "Ошибка запуска Docker"
    else
        log "✅ Docker уже установлен: $(docker --version)" "$GREEN"
    fi
    
    # Установка Docker Compose
    if ! command_exists docker-compose; then
        log "Установка Docker Compose..." "$YELLOW"
        show_progress "Установка Docker Compose"
        apt install -y docker-compose-plugin 2>&1 | tee -a "$LOG_FILE" > /dev/null
        check_status "Docker Compose установлен" "Ошибка установки Docker Compose"
    else
        log "✅ Docker Compose уже установлен: $(docker-compose --version)" "$GREEN"
    fi
    
    # Проверка работы Docker
    if ! docker ps &> /dev/null; then
        error_exit "Docker не работает. Проверьте: systemctl status docker"
    fi
    
    echo ""
}

# ============================================================
# НАСТРОЙКА FIREWALL
# ============================================================

setup_firewall() {
    log "Настройка файрвола..." "$YELLOW"
    
    # Проверка UFW
    if command_exists ufw; then
        if ufw status | grep -q "Status: active"; then
            show_progress "Настройка UFW"
            ufw allow 22/tcp 2>&1 | tee -a "$LOG_FILE" > /dev/null
            ufw allow 80/tcp 2>&1 | tee -a "$LOG_FILE" > /dev/null
            ufw allow 443/tcp 2>&1 | tee -a "$LOG_FILE" > /dev/null
            ufw allow 8000/tcp 2>&1 | tee -a "$LOG_FILE" > /dev/null
            check_status "UFW настроен" "Ошибка настройки UFW"
            log "✅ Порт 22 (SSH), 80 (HTTP), 443 (HTTPS), 8000 (API) открыты" "$GREEN"
        else
            log "⚠️  UFW не активен. Пропускаем настройку." "$YELLOW"
        fi
    fi
    
    echo ""
}

# ============================================================
# СБОР ДАННЫХ
# ============================================================

collect_data() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📝 ВВЕДИТЕ НЕОБХОДИМЫЕ ДАННЫЕ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${DIM}Все поля обязательны для заполнения.${NC}"
    echo ""
    
    # Telegram Bot
    echo -e "${BOLD}🤖 TELEGRAM BOT${NC}"
    echo -e "${DIM}Как получить:${NC}"
    echo -e "  ${DIM}1. Напишите @BotFather в Telegram${NC}"
    echo -e "  ${DIM}2. Отправьте /newbot${NC}"
    echo -e "  ${DIM}3. Придумайте имя и username (заканчивается на 'bot')${NC}"
    echo -e "  ${DIM}4. Скопируйте полученный токен${NC}"
    echo ""
    
    while true; do
        BOT_TOKEN=$(ask "Введите токен бота" "")
        if [ -n "$BOT_TOKEN" ]; then
            # Простая проверка токена
            if [[ "$BOT_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
                break
            else
                echo -e "${RED}❌ Неверный формат токена. Он должен быть вида: 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz${NC}"
            fi
        else
            echo -e "${RED}❌ Токен обязателен!${NC}"
        fi
    done
    
    echo ""
    
    # Telegram ID
    echo -e "${BOLD}👤 TELEGRAM ID${NC}"
    echo -e "${DIM}Как получить:${NC}"
    echo -e "  ${DIM}1. Найдите @userinfobot в Telegram${NC}"
    echo -e "  ${DIM}2. Отправьте ему любое сообщение${NC}"
    echo -e "  ${DIM}3. Бот пришлет ваш ID (цифры)${NC}"
    echo ""
    
    while true; do
        ADMIN_IDS=$(ask "Введите ваш Telegram ID" "")
        if [[ "$ADMIN_IDS" =~ ^[0-9]+$ ]]; then
            break
        else
            echo -e "${RED}❌ ID должен содержать только цифры!${NC}"
        fi
    done
    
    echo ""
    
    # 3x-ui Panel
    echo -e "${BOLD}🖥️  ПАНЕЛЬ 3X-UI${NC}"
    echo -e "${DIM}Данные от вашей установленной панели 3x-ui${NC}"
    echo ""
    
    XUI_HOST=$(ask "URL панели 3x-ui" "https://bedalagavpn.mooo.com:44300")
    XUI_USERNAME=$(ask "Логин от панели" "pavel")
    XUI_PASSWORD=$(ask "Пароль от панели" "pavel")
    
    echo ""
    
    # Domain
    echo -e "${BOLD}🌐 ДОМЕН${NC}"
    echo -e "${DIM}Домен, который будет использоваться для кабинета${NC}"
    echo ""
    
    DOMAIN=$(ask "Введите домен" "miniapp.bedalagavpn.mooo.com")
    
    echo ""
    
    # Подтверждение
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋 ПРОВЕРЬТЕ ВВЕДЕННЫЕ ДАННЫЕ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🤖 Токен бота:${NC} $BOT_TOKEN"
    echo -e "${GREEN}👤 Telegram ID:${NC} $ADMIN_IDS"
    echo -e "${GREEN}🖥️  Панель 3x-ui:${NC} $XUI_HOST"
    echo -e "${GREEN}👤 Логин:${NC} $XUI_USERNAME"
    echo -e "${GREEN}🌐 Домен:${NC} $DOMAIN"
    echo ""
    
    if ! confirm "Все верно?"; then
        echo -e "${YELLOW}🔄 Перезапустите скрипт для повторного ввода данных.${NC}"
        exit 0
    fi
}

# ============================================================
# СОЗДАНИЕ .ENV ФАЙЛА
# ============================================================

create_env_file() {
    log "Создание .env файла..." "$YELLOW"
    
    # Генерация секретных ключей
    JWT_SECRET=$(generate_secret)
    SECRET_KEY=$(generate_secret)
    
    cat > .env << EOF
# ============================================================
# YADRENO CABINET CONFIGURATION
# ============================================================
# Документация: https://github.com/porkgras/yadreno-cabinet
# Дата создания: $(date +'%Y-%m-%d %H:%M:%S')
# ============================================================

# ---------- TELEGRAM BOT ----------
BOT_TOKEN=$BOT_TOKEN
ADMIN_IDS=$ADMIN_IDS

# ---------- 3X-UI PANEL ----------
XUI_HOST=$XUI_HOST
XUI_USERNAME=$XUI_USERNAME
XUI_PASSWORD=$XUI_PASSWORD

# ---------- JWT SETTINGS ----------
JWT_SECRET_KEY=$JWT_SECRET
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# ---------- DATABASE ----------
DB_TYPE=sqlite
DB_PATH=/app/data/app.db

# ---------- CORS ----------
ALLOWED_ORIGINS=https://$DOMAIN,http://$DOMAIN,http://localhost:3000

# ---------- APP SETTINGS ----------
APP_NAME=Yadreno Cabinet
APP_DEBUG=false
APP_VERSION=1.0.0
SECRET_KEY=$SECRET_KEY

# ---------- REDIS (опционально) ----------
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# ---------- LOGGING ----------
LOG_LEVEL=info
LOG_FILE=/app/logs/app.log

# ---------- MAINTENANCE ----------
BACKUP_ENABLED=true
BACKUP_INTERVAL=86400  # 24 hours
BACKUP_RETENTION=7     # days
