# 🚀 Yadreno Cabinet

> Веб-кабинет для управления VPN-ключами с интеграцией 3x-ui

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/porkgras/yadreno-cabinet)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-✓-blue)](https://docker.com)
[![FastAPI](https://img.shields.io/badge/FastAPI-✓-green)](https://fastapi.tiangolo.com)
[![React](https://img.shields.io/badge/React-✓-cyan)](https://reactjs.org)

---

## 📋 Оглавление

- [🚀 Быстрая установка](#-быстрая-установка)
  - [Linux](#linux)
  - [macOS](#macos)
  - [Windows (WSL2)](#windows-wsl2)
  - [Windows (PowerShell)](#windows-powershell)
- [📥 Ручная установка](#-ручная-установка)
- [🔧 Проверка статуса](#-проверка-статуса)
- [🌐 Доступ после установки](#-доступ-после-установки)
- [📋 Требования](#-требования)
- [🛠️ Управление проектом](#️-управление-проектом)
- [🐛 Решение проблем](#-решение-проблем)
- [📁 Структура проекта](#-структура-проекта)
- [🤝 Поддержка](#-поддержка)
- [📄 Лицензия](#-лицензия)

---

## 🚀 Быстрая установка

### Linux

```bash
# Установка в один клик
bash <(curl -s https://raw.githubusercontent.com/porkgras/yadreno-cabinet/main/scripts/install.sh)

# Или через wget
bash <(wget -qO- https://raw.githubusercontent.com/porkgras/yadreno-cabinet/main/scripts/install.sh)

# Установка в один клик
bash <(curl -s https://raw.githubusercontent.com/porkgras/yadreno-cabinet/main/scripts/install.sh)

# Или через brew (если установлен)
brew install curl
curl -s https://raw.githubusercontent.com/porkgras/yadreno-cabinet/main/scripts/install.sh | bash

# 1. Откройте WSL2 (Ubuntu)
wsl

# 2. Выполните установку
bash <(curl -s https://raw.githubusercontent.com/porkgras/yadreno-cabinet/main/scripts/install.sh)

# 1. Откройте PowerShell от имени администратора
# 2. Установите WSL2
wsl --install

# 3. После перезагрузки откройте WSL2
wsl

# 4. Выполните установку
bash <(curl -s https://raw.githubusercontent.com/porkgras/yadreno-cabinet/main/scripts/install.sh)

# 1. Клонируйте репозиторий
git clone https://github.com/porkgras/yadreno-cabinet.git
cd yadreno-cabinet

# 2. Запустите установщик
chmod +x install.sh
./install.sh

# 3. Проверьте статус
yadreno-check

# Запуск диагностики (автоматическое исправление проблем)
yadreno-check

# Или
cd yadreno-cabinet && ./scripts/check-and-fix.sh
