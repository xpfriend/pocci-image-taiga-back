#!/bin/sh
set -e

/bin/sh /taiga/bin/config.sh

cd /taiga/taiga-back

while ! nc -z postgres 5432; do
  sleep 1
done

python manage.py migrate --noinput
python manage.py loaddata initial_user
python manage.py loaddata initial_project_templates
#python manage.py loaddata initial_role
python manage.py compilemessages
python manage.py collectstatic --noinput

/usr/local/bin/circusd /taiga/circus.ini
