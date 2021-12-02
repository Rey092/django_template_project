#!make
ENV_FILE_CHECK = local.env
ifneq ("$(wildcard $(ENV_FILE_CHECK))","")
	include local.env
	export $(shell sed 's/=.*//' local.env)
endif


MANAGE = python manage.py
SOURCE = src
MAIN = src
NAME = testb

PROJECT_DIR=$(shell pwd)
WSGI_PORT=8000


# ##########################################################################
# common commands

run:
	$(MANAGE) runserver 127.0.0.1:8001

tests:
	./manage.py test --parallel --noinput
celerybeat:
	celery -A config.celery_app beat -l info
celeryworker:
	celery -A config.celery_app worker -l info
flower:
	celery flower \
		--app=config.celery_app \
		--broker="${CELERY_BROKER_URL}" \
		--basic_auth="${CELERY_FLOWER_USER}:${CELERY_FLOWER_PASSWORD}"
prune:
	docker system prune -a --volumes --force

startapp:
	mkdir $(SOURCE)/apps/$(NAME)
	sleep 3
	django-admin startapp $(NAME) ./$(SOURCE)/apps/$(NAME)

# ##########################################################################
# deploy commands

gunicorn-run:
	$(MANAGE) collectstatic --no-input
	$(MANAGE) makemigrations --no-input
	$(MANAGE) migrate --no-input
	gunicorn config.wsgi -b 0.0.0.0:8000 --reload

# ##########################################################################
# management

migrations:
	$(MANAGE) makemigrations

migrate:
	$(MANAGE) migrate

shell: # only after 'make extensions-install'
	$(MANAGE) shell_plus --print-sql

# ##########################################################################
# Uncommon commands

super:
	$(MANAGE) createsuperuser

install:
	pip install -r requirements/local_req.txt
