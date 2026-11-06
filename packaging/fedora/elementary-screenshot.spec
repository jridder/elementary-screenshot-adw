%global appname io.elementary.screenshot

Name:           elementary-screenshot
Version:        8.0.1
Release:        100.adw%{?dist}
Summary:        Screenshot tool (elementary), ported to libadwaita

License:        LGPL-3.0-only
URL:            https://github.com/elementary/screenshot
Source0:        %{url}/archive/%{version}/screenshot-%{version}.tar.gz
Patch0:         0001-port-granite-to-libadwaita.patch

BuildRequires:  desktop-file-utils
BuildRequires:  gcc
BuildRequires:  gettext
BuildRequires:  libappstream-glib
BuildRequires:  meson
BuildRequires:  vala
BuildRequires:  pkgconfig(gdk-pixbuf-2.0)
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(gtk4)
BuildRequires:  pkgconfig(libadwaita-1) >= 1.4
BuildRequires:  pkgconfig(libportal)

Requires:       hicolor-icon-theme

%description
A simple screenshot tool from elementary OS, rebuilt against libadwaita
instead of Granite. Capture the whole screen, a window, or an area, then
save or copy the result.

%prep
%autosetup -n screenshot-%{version} -p1

%build
%meson
%meson_build

%install
%meson_install
%find_lang %{appname}

%check
desktop-file-validate %{buildroot}%{_datadir}/applications/%{appname}.desktop
appstream-util validate-relax --nonet %{buildroot}%{_metainfodir}/%{appname}.metainfo.xml || :

%files -f %{appname}.lang
%license COPYING
%doc README.md
%{_bindir}/%{appname}
%{_datadir}/applications/%{appname}.desktop
%{_datadir}/glib-2.0/schemas/%{appname}.gschema.xml
%{_datadir}/icons/hicolor/*/apps/%{appname}.svg
%{_metainfodir}/%{appname}.metainfo.xml

%changelog
* Wed Sep 30 2026 Jeff <jridder@gmail.com> - 8.0.1-100.adw
- Port from Granite to libadwaita for Fedora 45
