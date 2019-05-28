Name:           yummy-security
Version:        0.1.0
Release:        1%{?dist}
Summary:        Parse CEFS errata to find packages with security updates available.

License:        GPLv3
URL:            https://github.com/jstaf/yummy-security
Source0:        https://github.com/jstaf/yummy-security/archive/%{version}.tar.gz

BuildRequires:  golang >= 1.11.0

%description
yummy-security is a tool designed to allow security updates of CentOS systems
using information from CEFS (https://cefs.steve-meier.de/). Once installed, just
run yummy-security to get a list of packages that should be installed to perform
a security-only update.


%prep
%autosetup


%build
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p %{buildroot}/%{_bindir}
cp %{name}* %{buildroot}/%{_bindir}

%files

%defattr(-,root,root,-)
%attr(755, root, root) %{_bindir}/%{name}*

%changelog
* Fri May 24 2019 Jeff Stafford <jeff.stafford@protonmail.com>
- Initial test release.

