#!/bin/bash
# ============================================
# Yadreno Cabinet Update Script
# ============================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Обновление Yadreno Cabinet...${NC}"

# Сохранение .env
if [ -f .env ]; then
    cp .env .env.backup
    echo -e "${GREEN}✅ .env сохранен${NC}"
fi

# Скачивание обновлений
git pull origin main

# Восстановление .env
if [ -f .env.backup ]; then
    cp .env.backup .env
    rm .env.backup
    echo -e "${GREEN}✅ .env восстановлен${NC}"
fi

# Перезапуск
docker-compose down
docker-compose up -d --build

echo -e "${GREEN}✅ Обновление завершено!${NC}"
