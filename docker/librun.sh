#!/bin/sh

# The following variables and the create_containers function are required but live
# inside the dev.sh in the projects docker folder. Include this script as "source".

# declare container names for the project – tools container is started by tools command:
#
# containers="fsg_api fsg_db fsg_redis fsg_search fsg_worker fsg_web"
# container_tools="fsg_tools"

# declare image to perform docker build onto:
#
# images_build="fsg/tools fsg/search"

# compose containers:
#
# create_containers() {
# 	local links="--link fsg_api --link fsg_db --link fsg_redis --link fsg_search"
# 	local worker_volumes="--volumes-from=fsg_worker"
# 	local docker_api="-v /var/run/docker.sock:/var/run/docker.sock"
#
# 	docker create --name fsg_api $docker_api jarkt/docker-remote-api
# 	docker create --name fsg_db -p 27017:27017 mongo
# 	docker create --name fsg_redis redis
# 	docker create --name fsg_search -p 9200:9200 fsg/search
#
# 	docker create --name fsg_worker $links -v $(cd "$(dirname "$0")/.."; pwd):/cosmik/ --restart="on-failure" registry.csmk.it/cosmik/web_dev /cosmik/console.php trigger
# 	docker create --name fsg_web $links $worker_volumes -p 80:80 registry.csmk.it/cosmik/web_dev
# 	docker create -it --name fsg_tools $links $worker_volumes $docker_api fsg/tools
# }


if [ $# -lt 1 ]; then
	echo "usage: $(basename "$0") command..."
	echo ""
	echo "Commands:"
	echo "  build     Build docker images"
	echo "  create    Create docker container"
	echo "  rm        Remove docker container"
	echo "  rmi       Remove docker images"
	echo "  rmi-base  Remove base images for cosmik projects"
	echo "  start     Start containers"
	echo "  stop      Stop containers"
	echo "  kill      Kill containers"
	echo "  tools     Start and ssh into tools container"
	echo "  setup     Alias for \"build create start tools\""
	echo "  clean     Alias for \"kill rm rmi\""
	exit 1
fi

print() {
	if command -v tput > /dev/null; then
		local color_default=$(tput sgr0)
		local color_red=$(tput setaf 1)
		local color_green=$(tput setaf 2)
		local color_yellow=$(tput setaf 3)
		local color_blue=$(tput setaf 4)
		local color_white=$(tput setaf 7)
	fi

	case $1 in
		start)
			printf "${color_blue}$2${color_default}"
			if [ "$2" != "" ] && [ "$3" != "" ]; then
				printf " "
			fi
			echo "${color_yellow}$3${color_default}:"
		;;
		success)
			echo "${color_green}DONE: $2${color_default}"
		;;
		error)
			echo "${color_red}ERROR: $2${color_default}"
		;;
		*)
			eval "local color=\${color_$1}"
			printf "${color}$2${color_default}"
		;;
	esac
}

field_position() {
	local i=1
	for field in $2; do
		if [ "$1" = "$field" ]; then
			echo $i
			return 0
		fi
		i=$(($i+1))
	done
	return 1
}

run_cmd() {
	print start "$1" "$2"

	if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
		print error "check parameters"
		return 1
	fi

	for field in $3; do
		if [ "$1" = "docker" ] && [ "$2" = "build" ]; then
			local folder="$(dirname "$0")/${field##*/}"
			$1 $2 --tag=$field $folder
		else
			$1 $2 $field > /dev/null
		fi
		if [ $? -eq 0 ]; then
			print success "$2 $field"
		else
			print error "$2 $field failed"
		fi
	done

	echo ""
}

run_cmd_async() {
	print start "$1" "$2"

	if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
		print error "check parameters"
		return 1
	fi

	local pids=""
	for field in $3; do
		$1 $2 $field > /dev/null &
		pids="$pids $!"
	done

	for pid in $pids; do
		local pos=`field_position "$pid" "$pids"`
		local field_name=`echo $3 | cut -d " " -f $pos`
		if wait $pid; then
			print success "$2 $field_name"
		else
			print error "$2 $field_name failed"
		fi
	done

	echo ""
}

while [ ! -z "$1" ]; do
	case $1 in
		setup)
			$0 build create start tools
		;;
		clean)
			$0 kill rm rmi
		;;
		build)
			run_cmd docker build "$images_build"
		;;
		create)
			print start docker "create"
			if create_containers; then
				print success "create"
			else
				print error "create failed"
			fi
			echo ""
		;;
		rm)
			run_cmd_async docker rm "$containers $container_tools"
		;;
		rmi)
			run_cmd_async docker rmi "$images_build $images_live"
		;;
		rmi-base)
			run_cmd_async docker rmi "registry.csmk.it/cosmik/search registry.csmk.it/cosmik/web_dev registry.csmk.it/cosmik/tools registry.csmk.it/cosmik/web redis mongo jarkt/docker-remote-api"
		;;
		start)
			run_cmd docker start "$containers"
			app_dir="$(cd $(dirname "$0"); cd ..; pwd)/app/cache"
			rm -rf "$app_dir/config/" && rm -rf "$app_dir/content/" && rm -rf "$app_dir/templates/"
		;;
		stop)
			run_cmd_async docker stop "$containers $container_tools"
		;;
		kill)
			run_cmd_async docker kill "$containers $container_tools"
		;;
		tools)
			docker start -i "$container_tools"
		;;
		*)
			print error "unknown command $1"
		;;
	esac
	shift
done

exit 0
