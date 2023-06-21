## Скрипт деплоя проекта [Kittygram](https://github.com/aleksanderstartsev1984/infra_sprint1)
Данный скрипт предназначен для быстрого развёртывания проекта Kittygram
по протоколу HTTP на удалённом сервере.
Для запуска скрипта необходимы следующие данные:

- логин юзера
- IP сервера
- доменное имя(при наличии)

### Перед запуском скрипта убедится что папка находится в корневой директории.

Выполнить команду в терминале.
```sh
chmod 700 /deployment_script/installation_script.sh
./installation_script.sh
```
Скрипт `save.sh` пушит проект на github
```sh
chmod 700 /deployment_script/save.sh
./save.sh
```
