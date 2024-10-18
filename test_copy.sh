#!/bin/bash
echo "Тест 3: Проверка копирования файлов"

# Запуск основного скрипта
./laboratory.sh

# Проверка количества файлов в папке log
file_count=$(ls log | wc -l)

if [ $file_count -ge 5 ]; then
    echo "PASS: Все файлы скопированы."
else
    echo "FAIL: Файлы не скопированы корректно."
fi
