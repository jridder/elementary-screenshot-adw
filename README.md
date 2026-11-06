# Screenshot (libadwaita port)

A fork of [elementary/screenshot](https://github.com/elementary/screenshot) 8.0.1, the screenshot tool from elementary OS, ported from Granite to **libadwaita** so it runs on plain GNOME. Capture the whole screen, a window or an area, then save or copy the result.

## Install on Ubuntu / Debian

Install the build dependencies:

```bash
sudo apt install build-essential debhelper meson valac gettext desktop-file-utils libgtk-4-dev libadwaita-1-dev libportal-dev libportal-gtk4-dev
```

Build the package from the repo root, then install it:

```bash
dpkg-buildpackage -b -us -uc
```

```bash
sudo apt install ../elementary-screenshot_*_amd64.deb
```

Built on Ubuntu 26.10 (GTK 4.24, libadwaita 1.10).

## Fedora

`packaging/fedora/` has the RPM spec and the port as a patch against the upstream 8.0.1 tarball.

## Build with Meson

```bash
meson setup _build --prefix=/usr && meson compile -C _build && sudo meson install -C _build
```

## History

The first commit is upstream 8.0.1, unchanged. The second commit is the libadwaita port.

---

## Upstream README

[![Translation status](https://l10n.elementary.io/widgets/screenshot/-/svg-badge.svg)](https://l10n.elementary.io/engage/screenshot/?utm_source=widget)

![Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation

Run `flatpak-builder` to configure the build environment, download dependencies, build, and install

```bash
    flatpak-builder build io.elementary.screenshot.yml --user --install --force-clean --install-deps-from=appcenter
```

Then execute with

```bash
    flatpak run io.elementary.screenshot
```
