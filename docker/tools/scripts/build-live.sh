#!/bin/sh

image_tag="registry.csmk.it/dyndns/web_live"

print() {
	if command -v tput > /dev/null; then
		local color_default=$(tput sgr0)
		local color_red=$(tput setaf 1)
		local color_green=$(tput setaf 2)
	fi

	case $1 in
		success)
			echo "${color_green}DONE: $2${color_default}"
		;;
		error)
			echo "${color_red}ERROR: $2${color_default}"
		;;
	esac
}

exit_code=0

# Prepare workspace:
rm -rf /tmp/buildcontext
mkdir -p /tmp/buildcontext/cosmik

# Export project files:
cd /cosmik
git archive master | tar -x -C /tmp/buildcontext/cosmik

# Build web_live:
cd /tmp/buildcontext
cp /tmp/buildcontext/cosmik/docker/web_live/Dockerfile .
docker build --tag=$image_tag ./
if [ "$?" != "0" ]; then
	exit_code=1
	print error "docker build failed"
fi
rm Dockerfile

if [ "$exit_code" = "0" ]; then
	print success "$image_tag"
else
	print error "building $image_tag failed"
fi

exit $exit_code
