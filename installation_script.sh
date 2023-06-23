#!/usr/bin/bash
# Начать индикацию выполнения скрипта
timer_funce(){
    wile sleep 1; do echo -n "*" > &2; done
}
timer_funce &
timer_funce_pid=$!
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
# Установка пакетного менеджера snap
sudo apt install snapd
# Установка и обновление зависимостей для пакетного менеджера snap.
sudo snap install core
sudo snap refresh core
# Установка пакета certbot.
sudo snap install --classic certbot
# Создание ссылки на certbot в системной директории,
# чтобы у пользователя с правами администратора был доступ к этому пакету.
sudo ln -s /snap/bin/certbot /usr/bin/certbot
###############################################################################
# Установка проекта
###############################################################################
# Клонировать репозиторий(ссылку на репу легко меняется на свою)
git clone git@github.com:aleksanderstartsev1984/infra_sprint1.git
# Создать виртуальное окружение, устанавить зависимости
cd infra_sprint1/backend/
python3 -m venv venv
source venv/bin/activate
cd ..
pip install --upgrade pip
pip install -r requirements.txt
# Применить миграции
cd backend/
python3 manage.py migrate
# Создать суперпользователя
echo creating a superuser:
python3 manage.py createsuperuser
cd ..
# В директории infra_sprint1/backend/kittygram_backend/ создать файл .env
sudo cp /home/$login/deployment_script/env_default /home/$login/infra_sprint1/backend/kittygram_backend/.env
file=backend/kittygram_backend/.env
sudo sed -i -e s/ВашIP/$ip/g ${file}
sudo sed -i -e s/ВашДОМЕН/$domain/g ${file}
# Создать папку media и назначить текущего польвателя владельцем
sudo mkdir -p /var/www/infra_sprint1/media
sudo chown -R $login /var/www/infra_sprint1/media/
# Установить зависимости для фронтенда
cd frontend/
npm i
# Удалить старый юнит gunicorn(усли таковой имеется)
sudo rm -r /etc/systemd/system/gunicorn_kittygram.service
# Создать юнит для gunicorn
sudo cp /home/$login/deployment_script/gunicorn_kittygram /etc/systemd/system/gunicorn_kittygram.service
file=/etc/systemd/system/gunicorn_kittygram.service
sudo sed -i -e s/ВашЛОГИН/$login/g ${file}
# Запуск процеса gunicorn и добавление его в автозапуск, командами start,
# stop, restart можно управлять процессом
sudo systemctl start gunicorn_kittygram.service
sudo systemctl enable gunicorn_kittygram.service
# Проверить работоспособность запущенного демона
# sudo systemctl status gunicorn_kittygram
# Собрать статику фронтенда находясь в директории /infra_sprint1/frontend/
npm run build
# Копировать собранную статику в системную библиотеку
sudo cp -r /home/$login/infra_sprint1/frontend/build/. /var/www/infra_sprint1/
sudo rm -r /home/$login/infra_sprint1/frontend/node_modules
# Создать файл конфигурацуии Nginx
sudo rm -r /etc/nginx/sites-enabled/default
sudo cp /home/$login/deployment_script/nginx_default /etc/nginx/sites-enabled/default
file=/etc/nginx/sites-enabled/default
sudo sed -i -e s/ВашIP/$ip/g ${file}
sudo sed -i -e s/ВашДОМЕН/$domain/g ${file}
# Проверка файла конфигурации Nginx
# sudo nginx -t
# Получение SSL-сертификата
sudo certbot --nginx
# Перезапуск конфигурации Nginx
sudo systemctl reload nginx
# Собрать статику бэкэнда и копировать в системную директорию
cd ..
cd backend/
python3 manage.py collectstatic
sudo cp -r static_backend/ /var/www/infra_sprint1/
# sudo rm -r static_backend/
# Остановить индикацию выполнения скрипта
kill $timer_funce_pid
# Перезапустить сервер
sudo reboot
