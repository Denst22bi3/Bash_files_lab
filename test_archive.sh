#!/bin/bash
echo "Тест 4: Проверка архивации старых файлов"

# Запуск основного скрипта
./laboratory.sh

# Проверка наличия архива
if [ -f backup/old_files_backup.tar.gz ]; then
    echo "PASS: Файлы успешно заархивированы."
else
    echo "FAIL: Архивация не прошла."
fi
