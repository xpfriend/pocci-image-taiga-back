#!/bin/sh
set -e

TAIGA_SCHEME=${TAIGA_PROTOCOL%:*}

cat << EOF >/taiga/taiga-back/settings/local.py
from .common import *

MEDIA_URL = '${TAIGA_URL}/media/'
STATIC_URL = '${TAIGA_URL}/static/'
ADMIN_MEDIA_PREFIX = '${STATIC_URL}admin/'
SITES["api"]["domain"] = '${TAIGA_HOST}'
SITES["api"]["scheme"] = '${TAIGA_SCHEME}'
SITES["front"]["domain"] = '${TAIGA_HOST}'
SITES["front"]["scheme"] = '${TAIGA_SCHEME}'

SECRET_KEY = '${TAIGA_SECRET_KEY}'

DEBUG = ${DEBUG:-False}
TEMPLATE_DEBUG = ${DEBUG:-False}
PUBLIC_REGISTER_ENABLED = True

DEFAULT_FROM_EMAIL = '${TAIGA_MAIL_ADDRESS}'
SERVER_EMAIL = DEFAULT_FROM_EMAIL

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_USE_TLS = False
EMAIL_HOST = '${TAIGA_SMTP_HOST}'
EMAIL_PORT = ${TAIGA_SMTP_PORT}


DATABASES = {
   'default': {
       'ENGINE': 'django.db.backends.postgresql',
       'NAME': '${TAIGA_DB_NAME}',
       'USER': '${TAIGA_DB_USER}',
       'PASSWORD': '${TAIGA_DB_PASS}',
       'HOST': 'postgres',
       'PORT': '5432',
   }
}

MEDIA_ROOT = '/taiga/media'
STATIC_ROOT = '/taiga/static'


INSTALLED_APPS += ["taiga_contrib_ldap_auth"]

LDAP_SERVER = "${LDAP_URL}"
LDAP_PORT = 389
LDAP_BIND_DN = "${LDAP_BIND_DN}"
LDAP_BIND_PASSWORD = "${LDAP_BIND_PASSWORD}"
LDAP_SEARCH_BASE = "${LDAP_BASE_DN}"
LDAP_SEARCH_PROPERTY = "${LDAP_ATTR_LOGIN}"
LDAP_SEARCH_SUFFIX = None
LDAP_EMAIL_PROPERTY = "${LDAP_ATTR_MAIL}"
LDAP_FULL_NAME_PROPERTY = "displayName"
EOF


cat  << EOF > /taiga/circus.ini
[circus]
check_delay = 5
endpoint = tcp://127.0.0.1:5555
pubsub_endpoint = tcp://127.0.0.1:5556
statsd = true

[watcher:taiga]
working_dir = /taiga/taiga-back
cmd = /usr/local/bin/gunicorn
args = -w 3 -t 60 --pythonpath=. -b 0.0.0.0:8001 taiga.wsgi
uid = taiga
numprocesses = 1
autostart = true
send_hup = true

[env:taiga]
TERM=rxvt-256color
SHELL=/bin/bash
USER=taiga
LANG=en_US.UTF-8
HOME=/home/taiga
PYTHONPATH=/usr/local/lib/python3.4/site-packages
EOF
