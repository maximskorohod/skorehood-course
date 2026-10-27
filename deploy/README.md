# Лендинг практикума на VPS

Сайт `course.skorehood.com` — чистая статика (HTML + `assets/`), сборки нет.
Отдаёт nginx на VPS `202.61.226.3` (Debian 13, алиас `SSHVPSsiteAPP` в `~/.ssh/config`).

## Как обновить сайт

1. Правите `index.html` / `conditions/index.html` / `assets/`.
2. Коммитите (уезжает **только закоммиченное**, ровно `HEAD`):
   ```bash
   git add -A && git commit -m "правка лендинга"
   ```
3. Выкладываете одной командой из папки `course-site` (Git Bash):
   ```bash
   bash deploy/deploy.sh
   ```
   Скрипт заливает архив коммита во временную папку и подменяет ею старую,
   в конце проверяет, что `/conditions/` отвечает 200.

`git push` в GitHub по желанию — для истории. После переключения DNS GitHub Pages
сайт больше не отдаёт.

## Что где на сервере

| Что | Где |
|---|---|
| Файлы сайта | `/var/www/course.skorehood.com` |
| Конфиг nginx | `/etc/nginx/sites-available/course.skorehood.com.conf` (копия — `deploy/course.skorehood.com.conf`) |
| Сертификат | `/etc/letsencrypt/live/course.skorehood.com/`, продлевает `certbot.timer` сам |
| Firewall | ufw: 22 (limit), 80, 443 |
| Автообновления | `unattended-upgrades` включены |
| Swap | `/swapfile`, 2 ГБ |

Поменяли конфиг nginx — залить и перечитать:
```bash
scp deploy/course.skorehood.com.conf SSHVPSsiteAPP:/etc/nginx/sites-available/ && ssh SSHVPSsiteAPP "nginx -t && systemctl reload nginx"
```

## Проверка без DNS (по IP)

```bash
curl -sI --resolve course.skorehood.com:443:202.61.226.3 https://course.skorehood.com/conditions/
```

## DNS (Cloudflare, зона skorehood.com)

Было: `course` CNAME → `maximskorohod.github.io` (GitHub Pages).
Стало: `course` **A** → `202.61.226.3`, облако **серое** (DNS only), TTL Auto.

Откат: вернуть CNAME на `maximskorohod.github.io` — репозиторий и Pages не выключены.
