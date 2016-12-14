#based on http://stackoverflow.com/questions/880227/what-is-the-minimum-i-have-to-do-to-create-an-rpm-file

mkdir -p ~/rpmbuild/{RPMS,SRPMS,BUILD,SOURCES,SPECS,tmp}

cat <<EOF >~/.rpmmacros
%_topdir   %(echo $HOME)/rpmbuild
%_tmppath  %{_topdir}/tmp
EOF

mkdir -p journalbeat/etc/journalbeat
mkdir -p journalbeat/usr/bin
install -m 755 $ROOT/journalbeat journalbeat/usr/bin
install -m 644 $ROOT/etc/journalbeat.yml journalbeat/etc/journalbeat/

tar -zcvf journalbeat-$VERSION.tar.gz journalbeat/

cp journalbeat-$VERSION.tar.gz SOURCES/

cat <<EOF > SPECS/journalbeat.spec
%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Summary: journalbeat a journald beat shipper
Name: journalbeat
Version: $VERSION
Release: 1
License: Apache License 2.0
Group: Development/Tools
SOURCE0 : %{name}-%{version}.tar.gz
URL: https://github.com/mheese/journalbeat

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep
%setup -q

%build
# Empty section.

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}

# in builddir
cp -a * %{buildroot}


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%config(noreplace) %{_sysconfdir}/%{name}/%{name}.conf
%{_bindir}/*

%changelog
-Initial RPM

EOF

rpmbuild -ba SPECS/journalbeat.spec
