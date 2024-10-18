#!/bin/bash
echo "Тест 2: Проверка размера папки /log"

# Запуск основного скрипта
./laboratory.sh

# Проверка размера папки log
log_size=$(du -m log | cut -f1)

if [ $log_size -ge 500 ]; then
    echo "PASS: Папка /log весит минимум 0.5 ГБ."
else
    echo "FAIL: Папка /log весит меньше 0.5 ГБ."
fi
