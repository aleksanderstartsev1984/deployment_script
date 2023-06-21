#!/usr/bin/bash
###############################################################################
# Установка проекта(на удалённом сервере)
###############################################################################
# Запись переменных
read -p 'введите login:     ' login
read -p 'введите IP:        ' ip
read -p 'введите domain:    ' domain
###############################################################################
# Системные библиотеки
###############################################################################
# Обновить список доступных пакетов
sudo apt update
# Установить Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
# Установить и запустить Nginx
sudo apt install nginx -y
sudo systemctl start nginx
# Установить пакетный менеджер и утилиту для создания виртуального окружения
sudo apt install python3-pip python3-venv -y
# Настроить фаервол
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
# Проверка статуса фаевола
# sudo ufw status
###############################################################################
# Установка проекта
###############################################################################
# Клонировать репозиторий
git clone git@github.com:aleksanderstartsev1984/infra_sprint1.git
# Создать виртуальное окружение, устанавить зависимости
cd infra_sprint1/backend/
python3 -m venv venv
source venv/bin/activate
cd ..
pip install --upgrade pip
pip install -r requirements.txt
# Применить миграции
python manage.py migrate
# Создать суперпользователя
python manage.py createsuperuser
# В директории infra_sprint1/backend/kittygram_backend/ создать файл .env
cp env_default backend/kittygram_backend/.env
file=backend/kittygram_backend/.env
sed -i -e s/ВашIP/$ip/g ${file}
sed -i -e s/ВашДОМЕН/$domain/g ${file}
# Создать папку media и назначить текущего польвателя владельцем
sudo mkdir -p /var/www/infra_sprint1/media
sudo chown -R ВАШ ЛОГИН /var/www/infra_sprint1/media/
# Установить зависимости для фронтенда
cd frontend/
npm i
# Создать юнит для gunicorn
sudo cp gunicorn_kittygram /etc/systemd/system/gunicorn_kittygram.service
file=/etc/systemd/system/gunicorn_kittygram.service
sed -i -e s/ВашЛОГИН/$login/g ${file}
# Запуск процеса gunicorn и добавление его в автозапуск, командами start,
# stop, restart можно управлять процессом
sudo systemctl start gunicorn_kittygram
sudo systemctl enable gunicorn_kittygram
# Проверить работоспособность запущенного демона
sudo systemctl status gunicorn_kittygram
# Собрать статику фронтенда находясь в директории /infra_sprint1/frontend/
npm run build
# Копировать собранную статику в системную библиотеку
sudo cp -r /home/yc-user/taski/frontend/build/. /var/www/infra_sprint1/
# Создать файл конфигурацуии Nginx
rm -r /etc/nginx/sites-enabled/default
sudo cp nginx_default /etc/nginx/sites-enabled/default
file=/etc/nginx/sites-enabled/default
sed -i -e s/ВашIP/$ip/g ${file}
sed -i -e s/ВашДОМЕН/$domain/g ${file}
# Проверка файла конфигурации Nginx
# sudo nginx -t
# Перезапуск конфигурации Nginx
sudo systemctl reload nginx
# Собрать статику бэкэнда и копировать в системную директорию
cd ..
cd backend/
python manage.py collectstatic
sudo cp -r static_backend/ /var/www/infra_sprint1/
# Перезапустить сервер
sudo reboot
