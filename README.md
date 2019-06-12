yummy-security
================================================
A security patch tool for CentOS Linux.

As you're likely already aware, yum-plugin-security doesn't work on CentOS. 
This makes security-only patching difficult - typically the only option to patch
a CentOS system is to just install all available updates. In many scenarios, 
this may not be desirable. Perhaps uptime is critical and you want to update as 
little as possible to avoid accidentally breaking things. It would be much nicer
if we could install *only* security updates and nothing else. `yummy-security`
is designed to make the process of performing security-only updates on CentOS.

## What about yum-plugin-security and yum-cron?

But wait? Can't I install `yum-plugin-security` and run `yum update --security`? 
Doesn't it work if I set updates to "security" in `yum-cron`? The answer is no. 
Though `yum` can be run with the `--security` flag on CentOS, it won't actually 
do anything. 

CentOS does not supply security errata in its yum repositories, so almost all of
the time no security updates will show up for your system if you run 
`yum update --security`. The *only* case in which `yum update --security` will 
work as advertised is if there is a security update for a package installed from 
EPEL.

The `--security` option will only work on Red Hat Enterprise Linux, where Red 
Hat provides security errata as part of your subscription to the RHEL repos.

## What does yummy-security do?

Though there are no security errata in the official CentOS repos, it does exist
and can be used to determine where security updates are required. In this case,
CEFS provides CentOS security errata for use with Spacewalk (for the curious,
these errata are generated by CEFS by parsing the "CentOS Announce" mailing 
list). See the official CEFS website for more information: 
https://cefs.steve-meier.de/

yummy-security downloads the latest security errata from CEFS and compares the 
list of affected packages to the package versions installed on your system. If a
security update is available for your system, yummy-security will print the name
of the package to stdout. You can use this output as part of a script to perform
security-only patching of your systems.

## Usage

```bash
# print list of packages with security updates available
yummy-security

# print list of packages with affected versions
# (to be used for installing the latest security patch and NOTHING else)
yummy-security --minimal
```

## Installation

No pre-built binaries are provided. You should build them yourself - after all,
this is for security patching, right? 

Prerequisites:

* [Golang](https://golang.org/dl/)
* [Docker](https://docs.docker.com/install/)

```bash
# build the binary
go build

# build RPMs for both CentOS 6 and 7
make docker_rpm
```

## I just want to patch my system

Build the RPMs and install them on a system you'd like to patch:

```bash
# build yummy-security rpms for CentOS 6 and 7
make docker_rpm
```

To patch a system:

```bash
# patch base CentOS packages
sudo yum update -y $(yummy-security)

# patch packages that have been installed from EPEL
sudo yum update -y --security
```

## Disclaimer

yummy-security is not infallible. It's only as accurate as the security errata
from CEFS (which in turn is generated from the CentOS mailing lists). This 
script hasn't been tested on anything except CentOS 6 and 7. I think this 
disclaimer from the CEFS errata sums things up best:

> This software is provided AS IS. There are no guarantees. It might kill your cat.
