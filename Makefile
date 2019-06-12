.PHONY = clean, rpm, docker_rpm

# just build the plain old go binary via cross-compile
yummy-security:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

.docker-image-c%: Dockerfile
	docker build -t golang-rpmbuild:$* --build-arg EL_RELEASE=$* .

# build el7 and el6 rpms in docker containers
docker_rpm: yummy-security.spec .docker-image-c6 .docker-image-c7
	docker run -it --rm -v $(PWD):/root/yummy-security:Z golang-rpmbuild:6 \
	   	/root/yummy-security/run-docker-build.sh
	docker run -it --rm -v $(PWD):/root/yummy-security:Z golang-rpmbuild:7 \
	   	/root/yummy-security/run-docker-build.sh

# build rpm on host machine
rpm: yummy-security.spec
	spectool -g -R $<
	# skip generation of debuginfo package
	rpmbuild -bb --define "debug_package %{nil}" $<

clean:
	rm -f yummy-security *.rpm

