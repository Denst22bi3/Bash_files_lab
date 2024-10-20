@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Устанавливаем адрес LOG_DIR и BACKUP_DIR
set "LOG_DIR=C:\Users\my18f\OneDrive\Рабочий стол\Bash_files_lab-main"
set "BACKUP_DIR=C:\Users\my18f\OneDrive\Рабочий стол\Bash_files_lab-main\backups"

:: Создание файла весом 1 ГБ, если его ещё нет
set "IMG_FILE=%LOG_DIR%\log.img"
if not exist "%IMG_FILE%" (
    echo Создаю файл размером 1ГБ...
    fsutil file createnew "%IMG_FILE%" 1073741824
    if exist "%IMG_FILE%" (
        echo Файл log.img успешно создан.
    ) else (
        echo Не удалось создать файл log.img.
        exit /b 1
    )
) else (
    echo Файл log.img уже существует.
)

:: Запрос порога для архивации
set /p THRESHOLD_MB="Введите порог заполненности (в MB) для архивации: "

echo Папка для логов: %LOG_DIR%
echo Порог заполненности: %THRESHOLD_MB% MB
echo Папка для бэкапов: %BACKUP_DIR%

:: Проверка существования папки для бэкапов
if not exist "%BACKUP_DIR%" (
  echo Папка для бэкапов не существует. Создаю...
  mkdir "%BACKUP_DIR%"
  if exist "%BACKUP_DIR%" (
    echo Папка для бэкапов успешно создана.
  ) else (
    echo Не удалось создать папку для бэкапов.
    exit /b 1
  )
) else (
  echo Папка для бэкапов уже существует.
)

:: Получаем общий размер папки LOG_DIR в байтах через PowerShell
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-ChildItem -Path '%LOG_DIR%' -Recurse | Measure-Object -Property Length -Sum).Sum"') do (
  set "FOLDER_SIZE_B=%%a"
)

:: Проверяем, что переменная FOLDER_SIZE_B не пустая
if "!FOLDER_SIZE_B!"=="" (
  echo Ошибка: не удалось получить размер папки.
  exit /b 1
)

:: Преобразуем размер папки в мегабайты через PowerShell и округляем до целого числа
for /f "delims=" %%b in ('powershell -NoProfile -Command "[math]::Floor(%FOLDER_SIZE_B% / 1MB)"') do (
  set "FOLDER_SIZE_MB=%%b"
)

echo Размер папки (MB): !FOLDER_SIZE_MB!

:: Проверка превышения порога
if !FOLDER_SIZE_MB! LSS !THRESHOLD_MB! (
  echo Размер папки меньше порога. Архивация не требуется.
) else (
  echo Размер папки превышает порог. Необходима архивация.

  :: Выводим список файлов для проверки
  echo Файлы в папке для логов:
  dir /b /a-d "%LOG_DIR%"

  :: Архивируем N самых старых файлов без учета расширения (здесь 5 файлов)
  set "N=5"
  for /f "delims=" %%a in ('dir /b /a-d /o:d "%LOG_DIR%"') do (
    if !N! GTR 0 (
      echo Архивируем файл: %%a
      copy "%LOG_DIR%\%%a" "%BACKUP_DIR%\"
      del "%LOG_DIR%\%%a"
      set /a N-=1
    )
  )
)

echo Скрипт выполнен успешно.
endlocal
