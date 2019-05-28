.PHONY = clean, rpm, local_rpm

# just build the plain old go binary via cross-compile
yummy-security:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

# build el7 and el6 rpms in docker containers
docker_rpm: 
	docker run -it --rm -v $(PWD):/home/builder/yummy-security rpmbuild/centos7 \
	   	/home/builder/yummy-security/run-docker-build.sh

# build rpm on host machine
rpm: yummy-security.spec
	sudo yum-builddep -y $<
	# skip generation of debuginfo package and automatically fetch sources
	rpmbuild -bb --define "debug_package %{nil}" --undefine=_disable_source_fetch $<

clean:
	rm -f yummy-security *.rpm

