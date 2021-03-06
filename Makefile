# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Copyright (c) 2014 Mozilla Corporation
#
# Contributors:
# 2xyo <yohann@lepage.info>
# Yohann Lepage yohann@lepage.info
# Anthony Verez averez@mozilla.com
# Brandon Myers bmyers@mozilla.com

# usage:
#	make single-build	- build new single image from Dockerfile
#	make single-debug	- debug run already created image by tag
#	make single-try	- build and run in debug mode
# make single-run - run a single instance of MozDef
# make multiple-build - build new mozdef container environment (includes multiple containers)
# make multiple-clean - remove any mozdef container environments
# make multiple-run - run new mozdef environment from containers

NAME=mozdef
VERSION=0.1


single-build:
	docker build -f docker/Dockerfile -t $(NAME):$(VERSION) .

single-build-no-cache:
	docker build -f docker/Dockerfile --no-cache -t $(NAME):$(VERSION) .

single-run:
	docker run \
		-e TZ=UTC \
		-p 80:80 \
		-p 9090:9090 \
		-p 8080:8080 \
		-p 8081:8081 \
		-v mozdef-elasticsearch:/var/lib/elasticsearch \
		-v mozdef-mongodb:/var/lib/mongo \
		-v mozdef-rabbitmq:/var/lib/rabbitmq \
		-v mozdef-data:/opt/mozdef/envs/mozdef/data \
		-h $(NAME) --name $(NAME) -d $(NAME):$(VERSION)

single-debug:build
	docker run \
		-e TZ=UTC \
		-p 80:80 \
		-p 9090:9090 \
		-p 8080:8080 \
		-p 8081:8081 \
		-p 3002:3002 \
		-p 5672:5672 \
		-p 15672:15672 \
		-p 9200:9200 \
		-v mozdef-elasticsearch:/var/lib/elasticsearch \
		-v mozdef-mongodb:/var/lib/mongo \
		-v mozdef-rabbitmq:/var/lib/rabbitmq \
		-v mozdef-data:/opt/mozdef/envs/mozdef/data \
		-h $(NAME) -t -i $(NAME):$(VERSION) /bin/bash

single-try: single-build single-run

single-stop:
	docker stop $(NAME)

single-rm:
	docker rm -f $(NAME)

single-rebuild: single-build single-rm single-run

.PHONY: single-build single-debug single-run


multiple-run:
	docker-compose -f docker/compose/docker-compose.yml -p $(NAME) up -d

multiple-build:
	docker-compose -f docker/compose/docker-compose.yml -p $(NAME) build

multiple-stop:
	docker-compose -f docker/compose/docker-compose.yml -p $(NAME) stop

multiple-rebuild: multiple-build multiple-stop multiple-run
