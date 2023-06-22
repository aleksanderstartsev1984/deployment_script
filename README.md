## Скрипт деплоя проекта [Kittygram](https://github.com/aleksanderstartsev1984/infra_sprint1)
Данный скрипт предназначен для быстрого развёртывания проекта Kittygram
на удалённом сервере. Порт 8080.
Установка происходит с мего гита(при желании переделать ссылку клонирования репы).
Применяются миграции, создаётся суперюзер(необходимо ввести логин, почту и пароль).
У скриптов выставлены разрешения `700`.
Перед установкой удаляются старые настройки gunicorn и nginx.
Для запуска скрипта необходимы следующие данные:

- логин юзера
- IP сервера
- доменное имя(при наличии)

### Перед запуском скрипта убедится что папка находится в корневой директории
### (там куда попадаешь при входе на сервер).

Выполнить команду в терминале
```sh
deployment_script/installation_script.sh
```

Соглашаемся везде где просит. После ребута сервера проект доступен по адресу
```
https://ВашДОМЕН
```
Скрипт `save.sh` пушит проект на github.

### Автор

https://github.com/aleksanderstartsev1984
