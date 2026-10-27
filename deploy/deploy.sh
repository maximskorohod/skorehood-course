#!/usr/bin/env bash
# Выкладка лендинга на VPS одной командой:  bash deploy/deploy.sh
# Хост берётся из ~/.ssh/config (алиас SSHVPSsiteAPP), можно переопределить: HOST=... bash deploy/deploy.sh
set -euo pipefail
HOST="${HOST:-SSHVPSsiteAPP}"
DIR=/var/www/course.skorehood.com
cd "$(dirname "$0")/.."

# Сборки нет — сайт статический. Выкладываем ровно последний коммит (HEAD):
# незакоммиченные правки на сервер не попадают. autocrlf=false — чтобы на Windows
# не уехали CRLF. Служебные файлы отсекаем на сервере.
if [ -n "$(git status --porcelain -- . ':!deploy')" ]; then
  echo "Внимание: есть незакоммиченные правки, они НЕ уедут"
fi

git -c core.autocrlf=false archive --format=tar HEAD | ssh "$HOST" "set -e
  rm -rf $DIR.new && mkdir -p $DIR.new && tar -xf - -C $DIR.new
  rm -rf $DIR.new/deploy $DIR.new/CNAME $DIR.new/.nojekyll $DIR.new/*.md
  chown -R www-data:www-data $DIR.new
  rm -rf $DIR.old
  if [ -d $DIR ]; then mv $DIR $DIR.old; fi
  mv $DIR.new $DIR
  rm -rf $DIR.old"

echo "OK: выложен коммит $(git rev-parse --short HEAD) на $HOST:$DIR"
echo "https://course.skorehood.com/conditions/ -> $(curl -s -o /dev/null -w '%{http_code}' https://course.skorehood.com/conditions/)"
