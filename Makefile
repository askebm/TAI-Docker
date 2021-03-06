image=askebm/tai:amd-2
container_id_file = /tmp/tai_container_id

build:
	docker build -t $(image) .

buildrm:
	docker rmi $(image)

$(container_id_file) :
	xhost local:docker
	docker run -it \
		--cidfile $(container_id_file) \
		--device /dev/dri:/dev/dri \
		-e DISPLAY \
		-v $(shell pwd):$(shell pwd) \
		-e QT_X11_NO_MITSHM=1 \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v ~/.Xauthority:/root/.Xauthority \
		--cap-add sys_ptrace \
		-v /run/user/1000:/run/user/1000 \
		-e XDG_RUNTIME_DIR \
		--detach \
		--workdir $(shell pwd) \
		$(image) 
	@echo "Mounted $(shell pwd)"

start:
	xhost local:docker
	docker container start $(shell cat $(container_id_file) )

stop:
	docker container stop $(shell cat $(container_id_file) )

rm:
	docker container stop $(shell cat $(container_id_file) )
	docker container rm $(shell cat $(container_id_file) )
	rm -rf $(container_id_file)

enter: $(container_id_file)
	docker exec -it $(shell cat $(container_id_file)) bash

init: $(container_id_file)

clangd: $(container_id_file)
	docker exec -it $(shell cat $(container_id_file)) clangd-10


	
.PHONY: build buildrm start stop rm enter init clangd
help:
	@echo "build"
	@echo "buildrm"
	@echo "start"
	@echo "stop"
	@echo "rm"
	@echo "enter"
	@echo "init"
	@echo "clangd"
.PHONY: help

