#!/bin/sh

containers="dyndns_web"
container_tools="dyndns_tools"
images_build="dyndns/tools dyndns/web_dev"
images_live="registry.csmk.it/dyndns/web_live"

create_containers() {
	local web_volumes="--volumes-from=dyndns_web"
	local docker_api="-v /var/run/docker.sock:/var/run/docker.sock"

	docker create --name dyndns_web -v $(cd "$(dirname "$0")/.."; pwd):/cosmik/ -p 80:8080 dyndns/web_dev
	docker create -it --name dyndns_tools $web_volumes $docker_api dyndns/tools
}

source $(dirname "$0")/librun.sh
