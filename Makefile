NAME := node-hello
PKGS:=$(wildcard package*.json) 
export PKGS
SRCS:=$(wildcard *.json) $(wildcard *.js) Dockerfile
export SRCS
SAVEDOTS:=.gitignore .git
TMPDOTS:=$(filter-out $(SAVEDOTS),$(wildcard .[a-zA-Z]*))

install:
	npm install

.build: $(SRCS)
	@ echo "*** Building docker Image"
	docker build -t $(NAME) . >.docker.build.out 2>&1
	@ touch $@

build: .build

Dockerfile: Dockerfile.sh Makefile
	bash $@.sh > $@

bash: .build
	docker run -it --rm --entrypoint /bin/bash $(NAME)

.run: .build
	@ echo "*** Deleting existing container"
	- docker container rm -f "$(NAME)d" >/dev/null 2>&1
	@ echo "*** Starting new container"
	docker run -i -t --rm -p 43567:8080 -d --name "$(NAME)d" $(NAME) 
	@ touch $@

run: .run

test:
	curl localhost:43567

clean:
	rm -rf node_modules $(TMPDOTS) Dockerfile


.PHONY: install build run test clean
