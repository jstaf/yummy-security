.PHONY = clean

yummy-security:
	go build

rpm:
	rpmbuild -bb yummy-security.spec --define "_srcdir $PWD"
	cp ~/rpmbuild/RPMS/x86_64/yummy-security*.rpm .

clean:
	rm -f yummy-security *.rpm
