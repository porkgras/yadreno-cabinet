#!/bin/bash
# ============================================
# Yadreno Cabinet Backup Script
# ============================================

set -e

BACKUP_DIR="/root/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/yadreno-cabinet_$TIMESTAMP.tar.gz"

mkdir -p $BACKUP_DIR

echo "📦 Создание бэкапа..."

# Бэкап данных
tar -czf $BACKUP_FILE \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='*.pyc' \
    --exclude='__pycache__' \
    /root/yadreno-cabinet

# Бэкап .env
if [ -f /root/yadreno-cabinet/.env ]; then
    cp /root/yadreno-cabinet/.env $BACKUP_DIR/.env_$TIMESTAMP
fi

echo "✅ Бэкап создан: $BACKUP_FILE"
echo "📊 Размер: $(du -h $BACKUP_FILE | cut -f1)"
