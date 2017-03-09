Summary: Loway $PROJECTNAME$
Name: $PROJECTNAME$
Version: $VERSION$
Release: $RELEASE$
BuildArch: noarch
Source0: $TARFILENAME$
License: Proprietary
Group: Asterisk
BuildRoot: %{_builddir}/%{name}-root
Requires: qloaderd, queuemetrics, wget, perl
Vendor: Loway

%description
Attempts quick setup of QueueMetrics.
Works on Elastix.

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
* Tue May 17 2011 le
- first release



