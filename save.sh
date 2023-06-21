#!/usr/bin/bash
git add .
echo
read -p 'введите комментарий:   '
echo
git commit -m "$REPLY"
git push
