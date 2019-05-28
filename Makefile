.PHONY = clean, rpm, local_rpm

yummy-security:
	go build

rpm: yummy-security.spec
	sudo yum-builddep $<
	rpmbuild -bb --nodebuginfo --undefine=_disable_source_fetch $<
	cp ~/rpmbuild/RPMS/x86_64/yummy-security*.rpm .

clean:
	rm -f yummy-security *.rpm
