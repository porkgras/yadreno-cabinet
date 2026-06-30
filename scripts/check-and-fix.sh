#!/bin/bash

# ============================================================
# 🔧 YADRENO CABINET - СКРИПТ ДИАГНОСТИКИ И ВОССТАНОВЛЕНИЯ
# Версия: 2.0.0
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

# Переменные
PROJECT_DIR="/root/yadreno-cabinet"
ERRORS_FOUND=0
FIXED=0
NOT_FIXED=0

clear

# ============================================================
# БАННЕР
# ============================================================
echo -e "${BLUE}"
cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     🔧 YADRENO CABINET - ДИАГНОСТИКА И ВОССТАНОВЛЕНИЕ      ║
║                                                              ║
║     Автоматическое обнаружение и исправление проблем        ║
║     Версия: 2.0.0                                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"
echo ""

# ============================================================
# ФУНКЦИИ
# ============================================================

print_section() {
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${WHITE}$1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

ask_user() {
    local question="$1"
    local default="${2:-y}"
    local answer
    
    if [ "$default" = "y" ]; then
        read -p "$question (Y/n): " answer
        answer=${answer:-y}
    else
        read -p "$question (y/N): " answer
        answer=${answer:-n}
    fi
    
    [[ "$answer" =~ ^[Yy]$ ]]
}

check_container() {
    local service=$1
    docker-compose ps --services 2>/dev/null | grep -q "^$service$"
}

check_http() {
    local url=$1
    curl -s -o /dev/null -w '%{http_code}' "$url" 2>/dev/null | grep -q "^[23]"
}

check_ssl() {
    echo | openssl s_client -servername "$1" -connect "$1:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep -q "notAfter"
}

# ============================================================
# 1. ПРОВЕРКА КОНТЕЙНЕРОВ
# ============================================================
print_section "📦 1. ПРОВЕРКА КОНТЕЙНЕРОВ"

cd "$PROJECT_DIR" 2>/dev/null || {
    echo -e "${RED}❌ Папка проекта не найдена${NC}"
    exit 1
}

declare -A CONTAINERS=(
    ["backend"]="Бэкенд"
    ["frontend"]="Фронтенд"
    ["nginx"]="Nginx"
)

for service in "${!CONTAINERS[@]}"; do
    name="${CONTAINERS[$service]}"
    if check_container "$service"; then
        echo -e "   ${GREEN}✅${NC} $name работает"
    else
        echo -e "   ${RED}❌${NC} $name не запущен"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
        
        if ask_user "   🔧 Запустить $name?"; then
            echo -e "   ${YELLOW}⏳ Запуск $name...${NC}"
            docker-compose up -d "$service" 2>/dev/null
            sleep 3
            
            if check_container "$service"; then
                echo -e "   ${GREEN}✅ $name успешно запущен${NC}"
                FIXED=$((FIXED + 1))
            else
                echo -e "   ${RED}❌ Не удалось запустить $name${NC}"
                NOT_FIXED=$((NOT_FIXED + 1))
            fi
        else
            echo -e "   ${YELLOW}⏭️ Пропущено${NC}"
            NOT_FIXED=$((NOT_FIXED + 1))
        fi
    fi
done
echo ""

# ============================================================
# 2. ПРОВЕРКА БЭКЕНДА
# ============================================================
print_section "🔍 2. ПРОВЕРКА БЭКЕНДА"

if check_http "http://localhost:8000/health"; then
    echo -e "   ${GREEN}✅${NC} Бэкенд работает"
else
    echo -e "   ${RED}❌${NC} Бэкенд не отвечает"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
    
    if ask_user "   🔧 Перезапустить бэкенд?"; then
        echo -e "   ${YELLOW}⏳ Перезапуск бэкенда...${NC}"
        docker-compose restart backend 2>/dev/null
        sleep 5
        
        if check_http "http://localhost:8000/health"; then
            echo -e "   ${GREEN}✅ Бэкенд восстановлен${NC}"
            FIXED=$((FIXED + 1))
        else
            echo -e "   ${RED}❌ Бэкенд не восстановился${NC}"
            echo -e "   ${YELLOW}📋 Проверьте логи: docker-compose logs backend --tail=50${NC}"
            NOT_FIXED=$((NOT_FIXED + 1))
        fi
    else
        echo -e "   ${YELLOW}⏭️ Пропущено${NC}"
        NOT_FIXED=$((NOT_FIXED + 1))
    fi
fi
echo ""

# ============================================================
# 3. ПРОВЕРКА ФРОНТЕНДА
# ============================================================
print_section "🌐 3. ПРОВЕРКА ФРОНТЕНДА"

if check_http "http://localhost:3000"; then
    echo -e "   ${GREEN}✅${NC} Фронтенд работает"
else
    echo -e "   ${RED}❌${NC} Фронтенд не отвечает"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
    
    if ask_user "   🔧 Перезапустить фронтенд?"; then
        echo -e "   ${YELLOW}⏳ Перезапуск фронтенда...${NC}"
        docker-compose restart frontend 2>/dev/null
        sleep 5
        
        if check_http "http://localhost:3000"; then
            echo -e "   ${GREEN}✅ Фронтенд восстановлен${NC}"
            FIXED=$((FIXED + 1))
        else
            echo -e "   ${RED}❌ Фронтенд не восстановился${NC}"
            NOT_FIXED=$((NOT_FIXED + 1))
        fi
    else
        echo -e "   ${YELLOW}⏭️ Пропущено${NC}"
        NOT_FIXED=$((NOT_FIXED + 1))
    fi
fi
echo ""

# ============================================================
# 4. ПРОВЕРКА NIGNX
# ============================================================
print_section "🔒 4. ПРОВЕРКА NIGNX"

if check_http "http://miniapp.bedalagavpn.mooo.com"; then
    echo -e "   ${GREEN}✅${NC} Nginx работает"
else
    echo -e "   ${RED}❌${NC} Nginx не отвечает"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
    
    if ask_user "   🔧 Перезапустить Nginx?"; then
        echo -e "   ${YELLOW}⏳ Перезапуск Nginx...${NC}"
        docker-compose restart nginx 2>/dev/null
        sleep 3
        
        if check_http "http://miniapp.bedalagavpn.mooo.com"; then
            echo -e "   ${GREEN}✅ Nginx восстановлен${NC}"
            FIXED=$((FIXED + 1))
        else
            echo -e "   ${RED}❌ Nginx не восстановился${NC}"
            NOT_FIXED=$((NOT_FIXED + 1))
        fi
    else
        echo -e "   ${YELLOW}⏭️ Пропущено${NC}"
        NOT_FIXED=$((NOT_FIXED + 1))
    fi
fi
echo ""

# ============================================================
# 5. ПРОВЕРКА SSL
# ============================================================
print_section "🔐 5. ПРОВЕРКА SSL СЕРТИФИКАТА"

if check_ssl "miniapp.bedalagavpn.mooo.com"; then
    echo -e "   ${GREEN}✅${NC} SSL сертификат действителен"
    echo -e "   $(echo | openssl s_client -servername miniapp.bedalagavpn.mooo.com -connect miniapp.bedalagavpn.mooo.com:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | sed 's/^/   📅 /')"
else
    echo -e "   ${RED}❌${NC} SSL сертификат не найден или истек"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
    
    if ask_user "   🔧 Обновить SSL сертификат?"; then
        echo -e "   ${YELLOW}⏳ Обновление SSL...${NC}"
        docker-compose stop nginx 2>/dev/null
        certbot renew --quiet 2>/dev/null || certbot certonly --standalone -d miniapp.bedalagavpn.mooo.com --non-interactive --agree-tos --email porogras@mail.ru 2>/dev/null
        docker-compose start nginx 2>/dev/null
        sleep 3
        
        if check_ssl "miniapp.bedalagavpn.mooo.com"; then
            echo -e "   ${GREEN}✅ SSL сертификат обновлен${NC}"
            FIXED=$((FIXED + 1))
        else
            echo -e "   ${RED}❌ Не удалось обновить SSL${NC}"
            NOT_FIXED=$((NOT_FIXED + 1))
        fi
    else
        echo -e "   ${YELLOW}⏭️ Пропущено${NC}"
        NOT_FIXED=$((NOT_FIXED + 1))
    fi
fi
echo ""

# ============================================================
# 6. ПРОВЕРКА API
# ============================================================
print_section "📡 6. ПРОВЕРКА API"

if check_http "https://miniapp.bedalagavpn.mooo.com/health"; then
    echo -e "   ${GREEN}✅${NC} API работает"
else
    echo -e "   ${RED}❌${NC} API не отвечает"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
    
    if check_http "http://localhost:8000/health"; then
        echo -e "   ${YELLOW}⚠️ API работает локально, но не через Nginx${NC}"
        if ask_user "   🔧 Перезапустить Nginx?"; then
            docker-compose restart nginx 2>/dev/null
            sleep 3
            if check_http "https://miniapp.bedalagavpn.mooo.com/health"; then
                echo -e "   ${GREEN}✅ API восстановлен${NC}"
                FIXED=$((FIXED + 1))
            fi
        fi
    else
        echo -e "   ${RED}❌ API не работает ни локально, ни через Nginx${NC}"
        NOT_FIXED=$((NOT_FIXED + 1))
    fi
fi
echo ""

# ============================================================
# 7. ПРОВЕРКА 3X-UI
# ============================================================
print_section "🖥️  7. ПРОВЕРКА 3X-UI"

if check_http "https://bedalagavpn.mooo.com:44300/H6ckO7DAgMFwPkHc5Y/"; then
    echo -e "   ${GREEN}✅${NC} 3x-ui панель доступна"
else
    echo -e "   ${RED}❌${NC} 3x-ui панель не доступна"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
    
    if ask_user "   🔧 Перезапустить 3x-ui?"; then
        echo -e "   ${YELLOW}⏳ Перезапуск 3x-ui...${NC}"
        systemctl restart x-ui 2>/dev/null
        sleep 3
        
        if check_http "https://bedalagavpn.mooo.com:44300/H6ckO7DAgMFwPkHc5Y/"; then
            echo -e "   ${GREEN}✅ 3x-ui восстановлена${NC}"
            FIXED=$((FIXED + 1))
        else
            echo -e "   ${RED}❌ 3x-ui не восстановилась${NC}"
            echo -e "   ${YELLOW}💡 Запустите вручную: x-ui${NC}"
            NOT_FIXED=$((NOT_FIXED + 1))
        fi
    else
        echo -e "   ${YELLOW}⏭️ Пропущено${NC}"
        NOT_FIXED=$((NOT_FIXED + 1))
    fi
fi
echo ""

# ============================================================
# 8. ИТОГОВЫЙ ОТЧЕТ
# ============================================================
print_section "📊 8. ИТОГОВЫЙ ОТЧЕТ"

echo -e "${BOLD}${WHITE}РЕЗУЛЬТАТЫ ДИАГНОСТИКИ:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "   🔍 Найдено проблем: ${YELLOW}$ERRORS_FOUND${NC}"
echo -e "   ✅ Исправлено:     ${GREEN}$FIXED${NC}"
echo -e "   ⚠️  Не исправлено:  ${RED}$NOT_FIXED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ ВСЕ СИСТЕМЫ РАБОТАЮТ ИДЕАЛЬНО!${NC}"
elif [ $NOT_FIXED -eq 0 ] && [ $FIXED -gt 0 ]; then
    echo -e "${GREEN}✅ ВСЕ ПРОБЛЕМЫ УСПЕШНО ИСПРАВЛЕНЫ!${NC}"
else
    echo -e "${YELLOW}⚠️ НЕКОТОРЫЕ ПРОБЛЕМЫ ТРЕБУЮТ РУЧНОГО ВМЕШАТЕЛЬСТВА${NC}"
    echo ""
    echo -e "${YELLOW}💡 Рекомендации:${NC}"
    echo "   1. Проверьте логи: docker-compose logs -f"
    echo "   2. Проверьте доступность портов: netstat -tulpn | grep -E '8000|3000|80|443|44300'"
    echo "   3. Проверьте настройки .env файла"
    echo "   4. Попробуйте перезапустить все: docker-compose down && docker-compose up -d"
fi
echo ""

# ============================================================
# 9. ССЫЛКИ
# ============================================================
print_section "📌 9. ПОЛЕЗНЫЕ ССЫЛКИ"

echo -e "   🌐 Веб-кабинет: ${GREEN}https://miniapp.bedalagavpn.mooo.com${NC}"
echo -e "   📚 API Docs:    ${GREEN}https://miniapp.bedalagavpn.mooo.com/docs${NC}"
echo -e "   🖥️  3x-ui:       ${GREEN}https://bedalagavpn.mooo.com:44300/H6ckO7DAgMFwPkHc5Y/${NC}"
echo ""

# ============================================================
# ЗАВЕРШЕНИЕ
# ============================================================
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${GREEN}✅ ДИАГНОСТИКА ЗАВЕРШЕНА${NC}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

