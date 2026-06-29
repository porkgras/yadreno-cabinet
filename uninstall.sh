#!/bin/bash
# ============================================
# Yadreno Cabinet Uninstall Script
# ============================================

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}⚠️  ВНИМАНИЕ: Это действие удалит Yadreno Cabinet!${NC}"
read -p "Вы уверены? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Отмена"
    exit 0
fi

echo -e "${YELLOW}🗑️  Удаление Yadreno Cabinet...${NC}"

# Остановка контейнеров
docker-compose down -v 2>/dev/null || true

# Удаление образов
docker rmi yadreno-cabinet-backend yadreno-cabinet-frontend yadreno-cabinet-nginx 2>/dev/null || true

# Удаление файлов
cd /root
rm -rf yadreno-cabinet

echo -e "${YELLOW}✅ Yadreno Cabinet удален${NC}"
