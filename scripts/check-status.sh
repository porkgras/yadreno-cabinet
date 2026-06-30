#!/bin/bash

# ============================================================
# 📊 YADRENO CABINET - СКРИПТ ПРОВЕРКИ СТАТУСА
# Версия: 1.0.0
# Дата: 2026-06-30
# ============================================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Путь к проекту
PROJECT_DIR="/root/yadreno-cabinet"
cd "$PROJECT_DIR" 2>/dev/null || {
    echo -e "${RED}❌ Папка проекта не найдена: $PROJECT_DIR${NC}"
    exit 1
}

# Очищаем экран
clear

# ============================================================
# БАННЕР
# ============================================================
echo -e "${BLUE}"
cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     📊 YADRENO CABINET - СКРИПТ ПРОВЕРКИ СТАТУСА            ║
║                                                              ║
║     Автоматическая диагностика всех сервисов                ║
║     Версия: 1.0.0                                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

echo -e "${CYAN}📅 Дата проверки: $(date)${NC}"
echo -e "${CYAN}🖥️  Хост: $(hostname)${NC}"
echo -e "${CYAN}📂 Проект: $PROJECT_DIR${NC}"
echo ""

# ============================================================
# ФУНКЦИИ
# ============================================================

print_section() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${WHITE}$1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_service() {
    local name=$1
    local status=$2
    if [ "$status" = "ok" ] || [ "$status" = "200" ] || [ "$status" = "running" ]; then
        echo -e "   ${GREEN}✅ $name${NC}"
    else
        echo -e "   ${RED}❌ $name${NC}"
    fi
}

# ============================================================
# 1. ПРОВЕРКА КОНТЕЙНЕРОВ
# ============================================================
print_section "📦 1. СТАТУС DOCKER КОНТЕЙНЕРОВ"

if command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⏳ Проверка контейнеров...${NC}"
    docker-compose ps
    echo ""
    
    # Проверяем количество запущенных контейнеров
    RUNNING=$(docker-compose ps --services | wc -l)
    echo -e "${GREEN}✅ Запущено сервисов: $RUNNING${NC}"
else
    echo -e "${RED}❌ Docker Compose не установлен${NC}"
fi
echo ""

# ============================================================
# 2. ПРОВЕРКА БЭКЕНДА
# ============================================================
print_section "🔍 2. ПРОВЕРКА БЭКЕНДА"

echo -e "${YELLOW}⏳ Проверка health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8000/health)

if [ "$HEALTH_RESPONSE" = "200" ]; then
    echo -e "   ${GREEN}✅ Бэкенд работает (HTTP $HEALTH_RESPONSE)${NC}"
    echo -e "   📄 Информация:"
    curl -s http://localhost:8000/health | python3 -m json.tool 2>/dev/null | sed 's/^/      /'
else
    echo -e "   ${RED}❌ Бэкенд не отвечает (HTTP $HEALTH_RESPONSE)${NC}"
fi
echo ""

# ============================================================
# 3. ЛОГИ БЭКЕНДА
# ============================================================
print_section "📋 3. ПОСЛЕДНИЕ ЛОГИ БЭКЕНДА (10 строк)"

echo -e "${YELLOW}⏳ Получение логов...${NC}"
docker-compose logs --tail=10 backend 2>/dev/null | sed 's/^/   /'
echo ""

# ============================================================
# 4. ПРОВЕРКА ФРОНТЕНДА
# ============================================================
print_section "🌐 4. ПРОВЕРКА ФРОНТЕНДА"

echo -e "${YELLOW}⏳ Проверка фронтенда...${NC}"
FRONTEND_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000)

if [ "$FRONTEND_RESPONSE" = "200" ]; then
    echo -e "   ${GREEN}✅ Фронтенд работает (HTTP $FRONTEND_RESPONSE)${NC}"
else
    echo -e "   ${RED}❌ Фронтенд не отвечает (HTTP $FRONTEND_RESPONSE)${NC}"
fi
echo ""

# ============================================================
# 5. ПРОВЕРКА NIGNX (HTTP)
# ============================================================
print_section "🔒 5. ПРОВЕРКА NIGNX (HTTP)"

echo -e "${YELLOW}⏳ Проверка через HTTP...${NC}"
NGINX_HTTP_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' http://miniapp.bedalagavpn.mooo.com 2>/dev/null)

if [ "$NGINX_HTTP_RESPONSE" = "200" ] || [ "$NGINX_HTTP_RESPONSE" = "301" ] || [ "$NGINX_HTTP_RESPONSE" = "302" ]; then
    echo -e "   ${GREEN}✅ Nginx работает (HTTP $NGINX_HTTP_RESPONSE)${NC}"
else
    echo -e "   ${RED}❌ Nginx не отвечает (HTTP $NGINX_HTTP_RESPONSE)${NC}"
fi
echo ""

# ============================================================
# 6. ПРОВЕРКА HTTPS
# ============================================================
print_section "🔒 6. ПРОВЕРКА HTTPS"

echo -e "${YELLOW}⏳ Проверка HTTPS...${NC}"
HTTPS_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' https://miniapp.bedalagavpn.mooo.com 2>/dev/null)

if [ "$HTTPS_RESPONSE" = "200" ]; then
    echo -e "   ${GREEN}✅ HTTPS работает (HTTP $HTTPS_RESPONSE)${NC}"
else
    echo -e "   ${RED}❌ HTTPS не отвечает (HTTP $HTTPS_RESPONSE)${NC}"
fi
echo ""

# ============================================================
# 7. ПРОВЕРКА API ЧЕРЕЗ NIGNX
# ============================================================
print_section "📡 7. ПРОВЕРКА API ЧЕРЕЗ NIGNX (/health)"

echo -e "${YELLOW}⏳ Проверка API через Nginx...${NC}"
API_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' https://miniapp.bedalagavpn.mooo.com/health 2>/dev/null)

if [ "$API_RESPONSE" = "200" ]; then
    echo -e "   ${GREEN}✅ API работает через Nginx (HTTP $API_RESPONSE)${NC}"
    echo -e "   📄 Ответ API:"
    curl -s https://miniapp.bedalagavpn.mooo.com/health 2>/dev/null | python3 -m json.tool 2>/dev/null | sed 's/^/      /'
else
    echo -e "   ${RED}❌ API не отвечает через Nginx (HTTP $API_RESPONSE)${NC}"
fi
echo ""

# ============================================================
# 8. ПРОВЕРКА БАЗЫ ДАННЫХ
# ============================================================
print_section "💾 8. ПРОВЕРКА БАЗЫ ДАННЫХ"

echo -e "${YELLOW}⏳ Проверка файлов базы данных...${NC}"
docker exec -it yadreno-backend ls -la /app/data/ 2>/dev/null | sed 's/^/   /' || echo -e "   ${RED}❌ Папка data не найдена${NC}"
echo ""

# ============================================================
# 9. ПРОВЕРКА API ЭНДПОИНТОВ
# ============================================================
print_section "👤 9. ПРОВЕРКА API ЭНДПОИНТОВ"

echo -e "${YELLOW}⏳ Проверка /api/users/...${NC}"
USERS_RESPONSE=$(curl -s http://localhost:8000/api/users/ 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✅ /api/users/ доступен${NC}"
    echo "$USERS_RESPONSE" | python3 -m json.tool 2>/dev/null | sed 's/^/      /'
else
    echo -e "   ${RED}❌ /api/users/ не доступен${NC}"
fi
echo ""

echo -e "${YELLOW}⏳ Проверка /api/tariffs/...${NC}"
TARIFFS_RESPONSE=$(curl -s http://localhost:8000/api/tariffs/ 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✅ /api/tariffs/ доступен${NC}"
    echo "$TARIFFS_RESPONSE" | python3 -m json.tool 2>/dev/null | sed 's/^/      /'
else
    echo -e "   ${RED}❌ /api/tariffs/ не доступен${NC}"
fi
echo ""

# ============================================================
# 10. ПРОВЕРКА 3X-UI
# ============================================================
print_section "🖥️  10. ПРОВЕРКА 3X-UI ПАНЕЛИ"

echo -e "${YELLOW}⏳ Проверка доступности 3x-ui...${NC}"
XUI_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' https://bedalagavpn.mooo.com:44300/H6ckO7DAgMFwPkHc5Y/ 2>/dev/null)

if [ "$XUI_RESPONSE" = "200" ] || [ "$XUI_RESPONSE" = "302" ] || [ "$XUI_RESPONSE" = "301" ]; then
    echo -e "   ${GREEN}✅ 3x-ui панель доступна (HTTP $XUI_RESPONSE)${NC}"
else
    echo -e "   ${RED}❌ 3x-ui панель не доступна (HTTP $XUI_RESPONSE)${NC}"
fi
echo ""

# ============================================================
# 11. SSL СЕРТИФИКАТ
# ============================================================
print_section "🔐 11. ИНФОРМАЦИЯ О SSL СЕРТИФИКАТЕ"

echo -e "${YELLOW}⏳ Проверка SSL сертификата...${NC}"
SSL_INFO=$(echo | openssl s_client -servername miniapp.bedalagavpn.mooo.com -connect miniapp.bedalagavpn.mooo.com:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)

if [ -n "$SSL_INFO" ]; then
    echo -e "   ${GREEN}✅ SSL сертификат найден${NC}"
    echo "$SSL_INFO" | sed 's/^/   /'
else
    echo -e "   ${RED}❌ SSL сертификат не найден${NC}"
fi
echo ""

# ============================================================
# 12. ИТОГОВЫЙ СТАТУС
# ============================================================
print_section "📊 12. ИТОГОВЫЙ СТАТУС"

echo -e "${BOLD}${WHITE}КРАТКИЙ ИТОГ:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -n "   🔹 Контейнеры: "
RUNNING=$(docker-compose ps --services | wc -l 2>/dev/null || echo "0")
echo -e "$RUNNING сервисов запущено"

echo -n "   🔹 Бэкенд: "
if [ "$HEALTH_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Работает${NC}"
else
    echo -e "${RED}❌ Не работает${NC}"
fi

echo -n "   🔹 Фронтенд: "
if [ "$FRONTEND_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Работает${NC}"
else
    echo -e "${RED}❌ Не работает${NC}"
fi

echo -n "   🔹 Nginx: "
if [ "$NGINX_HTTP_RESPONSE" = "200" ] || [ "$NGINX_HTTP_RESPONSE" = "301" ] || [ "$NGINX_HTTP_RESPONSE" = "302" ]; then
    echo -e "${GREEN}✅ Работает${NC}"
else
    echo -e "${RED}❌ Не работает${NC}"
fi

echo -n "   🔹 HTTPS: "
if [ "$HTTPS_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Работает${NC}"
else
    echo -e "${RED}❌ Не работает${NC}"
fi

echo -n "   🔹 API: "
if [ "$API_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Работает${NC}"
else
    echo -e "${RED}❌ Не работает${NC}"
fi

echo -n "   🔹 3x-ui: "
if [ "$XUI_RESPONSE" = "200" ] || [ "$XUI_RESPONSE" = "302" ] || [ "$XUI_RESPONSE" = "301" ]; then
    echo -e "${GREEN}✅ Доступна${NC}"
else
    echo -e "${RED}❌ Не доступна${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================
# 13. ПОЛЕЗНЫЕ ССЫЛКИ
# ============================================================
print_section "📌 13. ПОЛЕЗНЫЕ ССЫЛКИ"

echo -e "   ${GREEN}➜ Веб-кабинет:${NC} https://miniapp.bedalagavpn.mooo.com"
echo -e "   ${GREEN}➜ API Docs:${NC}    https://miniapp.bedalagavpn.mooo.com/docs"
echo -e "   ${GREEN}➜ 3x-ui Panel:${NC} https://bedalagavpn.mooo.com:44300/H6ckO7DAgMFwPkHc5Y/"
echo ""

# ============================================================
# 14. КОМАНДЫ ДЛЯ УПРАВЛЕНИЯ
# ============================================================
print_section "💡 14. ПОЛЕЗНЫЕ КОМАНДЫ"

echo -e "   ${YELLOW}Просмотр логов:${NC}     docker-compose logs -f"
echo -e "   ${YELLOW}Перезапуск всех:${NC}    docker-compose restart"
echo -e "   ${YELLOW}Перезапуск бэкенда:${NC} docker-compose restart backend"
echo -e "   ${YELLOW}Остановка всех:${NC}     docker-compose down"
echo -e "   ${YELLOW}Запуск всех:${NC}        docker-compose up -d"
echo ""

# ============================================================
# ЗАВЕРШЕНИЕ
# ============================================================
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${GREEN}✅ ПРОВЕРКА ЗАВЕРШЕНА${NC}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Сохраняем результат в файл
REPORT_FILE="$PROJECT_DIR/status-report-$(date +%Y%m%d_%H%M%S).txt"
echo -e "${CYAN}📄 Отчет сохранен в: $REPORT_FILE${NC}"
echo ""

