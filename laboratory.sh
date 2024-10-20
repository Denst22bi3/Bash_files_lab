#!/bin/bash

# Создание папки фиксированного размера
# dd if=/dev/zero of=~/lab_bash/Fixed_size.img bs=1M count=100
# mkfs.ext4 ~/lab_bash/Fixed_size.img
# cd lab_bash
# sudo mount -o loop Fixed_size.img log 
# sudo umount /home/lab_bash/log - размонтировка папки

# Создание папки размером 1ГБ
LOG_DIR="log"
if [ ! -d "$LOG_DIR" ]; then
    sudo mkdir -p log
    sudo dd if=/dev/zero of=log.img bs=1M count=1024
    sudo mkfs.ext4 log.img
    sudo mount -o loop log.img log

    # Перекидывание тестовых файлов для работы этого скрипта
    sudo cp 1.txt log
    sudo cp 2.txt log
    sudo cp 3.txt log
    sudo cp 4.txt log
    sudo cp 5.txt log
    sudo cp sixth.txt log
else
    echo -e "\n Папка уже создана"
fi

echo -e "\n введите путь к директории и заполненость:"
read path_to
read PERSENTAGE

echo -e "\n ваша директория содержит файлы и папки:"
ls $path_to


# ИЗ-ЗА ЭТОГО МЕНЯ ЗАБЛОКИРОВАЛ ЛИНУКС
#Чтобы сохранить монтирование после перезагрузки, вы можете добавить запись в файл /etc/fstab:
# sudo echo "tmpfs /lab_bash/log tmpfs size=1G 0 0" >> /etc/fstab
# или
# sudo echo "/lab_bash/log.img /lab_bash/log ext4 loop 0 0" >> /etc/fstab
#Это позволит автоматически смонтировать файловую систему при запуске системы.
# Если вылезает с ошибка с доступом
# sudo sh -c "echo 'log.img /log ext4 loop 0 0' >> /etc/fstab"

# Извлекаем процент использования
size=$(df "$path_to" | awk 'NR==2 {print $5}')

# Выводим результат
echo "Процент использования папки '$path_to': $size"

# Создаем бекап папку, если ее нет
if [ $size \> $PERSENTAGE ]; then
    BACKUP_DIR="backup"
    if [ ! -d "$BACKUP_DIR" ]; then
        sudo mkdir "$BACKUP_DIR"
    else
        echo -e "\n Папка уже создана"
    fi

    # Фильтрация и архивация файлов
    num_files=5
    # Находим N самых старых файлов в директории LOG_DIR
    FILES=($(ls -t "$path_to" | tail -n $num_files))

    # Проверяем, найдены ли файлы
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "Нет подходящих файлов для архивации."
        exit 1
    fi

    # Архивируем файлы в директории BACKUP_DIR
    tar -czf "$BACKUP_DIR/old_files_backup.tar.gz" -C "$path_to" "${FILES[@]}"

    # Удаляем файлы из директории LOG_DIR
    for file in "${FILES[@]}"; do
        sudo rm "$path_to/$file"
    done

    echo "Архивация завершена. Архив сохранен как $BACKUP_DIR/old_files_backup.tar.gz и файлы удалены из $path_to."
fi

sudo rm -R log
