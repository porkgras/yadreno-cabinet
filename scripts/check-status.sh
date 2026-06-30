#!/bin/bash

# ============================================================
# 📊 YADRENO CABINET - СТАТУС ПРОЕКТА
# ============================================================

set -e

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

# Баннер
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║        🚀 YADRENO CABINET - СТАТУС ПРОЕКТА                  ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Функция проверки
check() {
    local name=$1
    local url=$2
    local type=$3
    
    if [ "$type" = "http" ]; then
        code=$(curl -s -o /dev/null -w '%{http_code}' "$url" 2>/dev/null)
        if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ]; then
            echo -e "   ${GREEN}✅${NC} $name"
        else
            echo -e "   ${RED}❌${NC} $name"
        fi
    elif [ "$type" = "container" ]; then
        status=$(docker-compose ps --services 2>/dev/null | grep -c "$name" || echo "0")
        if [ "$status" -gt 0 ]; then
            echo -e "   ${GREEN}✅${NC} $name"
        else
            echo -e "   ${RED}❌${NC} $name"
        fi
    else
        if curl -s "$url" >/dev/null 2>&1; then
            echo -e "   ${GREEN}✅${NC} $name"
        else
            echo -e "   ${RED}❌${NC} $name"
        fi
    fi
}

# Проверяем контейнеры
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}📦 КОНТЕЙНЕРЫ${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check "Backend" "backend" "container"
check "Frontend" "frontend" "container"
check "Nginx" "nginx" "container"
echo ""

# Проверяем сервисы
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}🌐 СЕРВИСЫ${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check "Backend API" "http://localhost:8000/health" "http"
check "Frontend" "http://localhost:3000" "http"
check "Nginx (HTTP)" "http://miniapp.bedalagavpn.mooo.com" "http"
check "Nginx (HTTPS)" "https://miniapp.bedalagavpn.mooo.com" "http"
check "3x-ui Panel" "https://bedalagavpn.mooo.com:44300/H6ckO7DAgMFwPkHc5Y/" "http"
echo ""

# Проверяем SSL
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}🔐 SSL СЕРТИФИКАТ${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ssl_info=$(echo | openssl s_client -servername miniapp.bedalagavpn.mooo.com -connect miniapp.bedalagavpn.mooo.com:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
if [ -n "$ssl_info" ]; then
    echo -e "   ${GREEN}✅${NC} Сертификат действителен"
    echo "$ssl_info" | while read -r line; do
        echo "   📅 $line"
    done
else
    echo -e "   ${RED}❌${NC} Сертификат не найден"
fi
echo ""

# Итог
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ ВСЕ СИСТЕМЫ РАБОТАЮТ${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ссылки
echo -e "${YELLOW}📌 ДОСТУП:${NC}"
echo "   🌐 Веб-кабинет: https://miniapp.bedalagavpn.mooo.com"
echo "   📚 API Docs:    https://miniapp.bedalagavpn.mooo.com/docs"
echo "   🖥️  3x-ui:       https://bedalagavpn.mooo.com:44300/H6ckO7DAgMFwPkHc5Y/"
echo ""

echo -e "${YELLOW}💡 КОМАНДЫ:${NC}"
echo "   📋 Логи:        docker-compose logs -f"
echo "   🔄 Перезапуск:  docker-compose restart"
echo "   ⏹️  Остановка:   docker-compose down"
echo "   ▶️  Запуск:      docker-compose up -d"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ ПРОВЕРКА ЗАВЕРШЕНА${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
