Summary: QueueMetrics Espresso
Name: queuemetrics-espresso
Version: _VERSION_
Release: _RELEASE_
BuildArch: _ARCH_
Source0: espresso.tar.gz
License: Proprietary
Group: Asterisk
BuildRoot: %{_builddir}/%{name}-root
Requires: uniloader, queuemetrics, wget, perl, psmisc
Vendor: Loway

%description
Attempts a quick setup of QueueMetrics.

%prep
rm -rf %{buildroot}
%setup -n %{name}-%{version}

%build

%install
mkdir -p $RPM_BUILD_ROOT/usr/local/queuemetrics/espresso

find . -name '*.sh' -type f -print | xargs chmod a+x
find . -name '*.pl' -type f -print | xargs chmod a+x
find . -name '*.sh' -type f -print | xargs dos2unix
find . -name '*.pl' -type f -print | xargs dos2unix
cp -R . $RPM_BUILD_ROOT/usr/local/queuemetrics/espresso


%clean
rm -rf $RPM_BUILD_ROOT
rm -rf %{_tmppath}/%{name}
rm -rf %{_topdir}/BUILD/%{name}

%files
%defattr(-,root,root)
/usr/local/queuemetrics/espresso

%post
PWD=`pwd`
cd /usr/local/queuemetrics/espresso
./qmEspresso.pl
cd $PWD

%changelog
* Thu Mar 9 2017 le
- first release on GitHub - uses Uniloader
* Tue May 17 2011 le
- first release




