/*
* Copyright (c) 2014–2016 Fabio Zaramella <ffabio.96.x@gmail.com>
*               2017–2022 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License version 3 as published by the Free Software Foundation.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Artem Anufrij <artem.anufrij@live.de>
*              Fabio Zaramella <ffabio.96.x@gmail.com>
*/

public class Screenshot.SaveDialog : Adw.Window {
    public Gdk.Pixbuf pixbuf { get; construct; }
    public Settings settings { get; construct; }

    public signal void save_response (bool response, string folder_dir, string output_name, string format);

    private const string[] FORMATS = { "png", "jpeg", "bmp", "tiff" };

    private Adw.ActionRow location_row;
    private Gtk.Image folder_image;
    private string folder_dir;

    public SaveDialog (Gdk.Pixbuf pixbuf, Settings settings) {
        Object (
            deletable: false,
            modal: true,
            pixbuf: pixbuf,
            settings: settings,
            title: _("Screenshot")
        );
    }

    construct {
        var pictures_dir = Environment.get_user_special_dir (UserDirectory.PICTURES);
        if (pictures_dir == null) {
            pictures_dir = Path.build_filename (Environment.get_home_dir (), "Pictures");
        }
        folder_dir = Path.build_filename (pictures_dir, Application.SAVE_FOLDER);

        var folder_from_settings = settings.get_string ("folder-dir");

        if (folder_from_settings != folder_dir && folder_from_settings != "") {
            folder_dir = folder_from_settings;
        }

        Application.create_dir_if_missing (folder_dir);

        var drag_source = new Gtk.DragSource () {
            actions = COPY,
            content = new Gdk.ContentProvider.for_value (pixbuf)
        };
        drag_source.set_icon (
            Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).lookup_icon (
                "image-x-generic",
                null,
                32,
                scale_factor,
                NONE,
                PRELOAD
            ), 0, 0
        );

        var preview = new Gtk.Picture.for_paintable (Gdk.Texture.for_pixbuf (pixbuf)) {
            height_request = 128,
            content_fit = Gtk.ContentFit.CONTAIN,
            overflow = Gtk.Overflow.HIDDEN
        };
        preview.add_css_class ("card");
        preview.add_controller (drag_source);

        var date_time = new GLib.DateTime.now_local ().format ("%Y-%m-%d %H.%M.%S");

        /// TRANSLATORS: %s represents a timestamp here
        var file_name = _("Screenshot from %s").printf (date_time);

        if (this.scale_factor > 1) {
            file_name += "@%ix".printf (this.scale_factor);
        }

        var name_row = new Adw.EntryRow () {
            title = _("Name"),
            text = file_name,
            activates_default = true
        };

        var format_row = new Adw.ComboRow () {
            title = _("File Type"),
            model = new Gtk.StringList (FORMATS)
        };

        var current_format = settings.get_string ("format");
        for (uint i = 0; i < FORMATS.length; i++) {
            if (FORMATS[i] == current_format) {
                format_row.selected = i;
                break;
            }
        }

        folder_image = new Gtk.Image ();

        var folder_button = new Gtk.Button.from_icon_name ("document-open-symbolic") {
            tooltip_text = _("Select Screenshots Folder…"),
            valign = Gtk.Align.CENTER
        };
        folder_button.add_css_class ("flat");

        location_row = new Adw.ActionRow () {
            title = _("Folder"),
            activatable_widget = folder_button
        };
        location_row.add_prefix (folder_image);
        location_row.add_suffix (folder_button);

        update_location_row (folder_dir);

        var group = new Adw.PreferencesGroup () {
            title = _("Save Image as…")
        };
        group.add (name_row);
        group.add (format_row);
        group.add (location_row);

        var validation_label = new Gtk.Label ("") {
            halign = Gtk.Align.START,
            wrap = true,
            xalign = 0
        };
        validation_label.add_css_class ("caption");
        validation_label.add_css_class ("error");

        var name_message_revealer = new Gtk.Revealer () {
            child = validation_label,
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };

        var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 18) {
            margin_top = 12,
            margin_bottom = 18,
            margin_start = 18,
            margin_end = 18
        };
        content.append (preview);
        content.append (group);
        content.append (name_message_revealer);

        var clipboard_btn = new Gtk.Button.with_label (_("Copy to Clipboard"));

        var retry_btn = new Gtk.Button.with_label (_("Cancel"));

        var save_btn = new Gtk.Button.with_label (_("Save")) {
            receives_default = true
        };
        save_btn.add_css_class ("suggested-action");

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin_top = 6,
            margin_bottom = 12,
            margin_start = 18,
            margin_end = 18
        };
        button_box.append (clipboard_btn);
        var spacer = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true
        };
        button_box.append (spacer);
        button_box.append (retry_btn);
        button_box.append (save_btn);

        var header = new Adw.HeaderBar () {
            show_end_title_buttons = false,
            show_start_title_buttons = false
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = content
        };
        toolbar_view.add_top_bar (header);
        toolbar_view.add_bottom_bar (button_box);

        // Prevent large dialog size with large screenshots
        default_width = 500;
        this.content = toolbar_view;
        default_widget = save_btn;

        name_row.grab_focus ();

        name_row.changed.connect (() => {
            bool valid = true;
            if (name_row.text.length == 0) {
                validation_label.label = _("Filename can't be blank");
                valid = false;
            } else if (name_row.text.contains ("/")) {
                validation_label.label = _("Filename can't contain “/”");
                valid = false;
            }

            if (valid) {
                name_row.remove_css_class ("error");
            } else {
                name_row.add_css_class ("error");
            }

            name_message_revealer.reveal_child = !valid;
            save_btn.sensitive = valid;
        });

        save_btn.clicked.connect (() => {
            save_response (true, folder_dir, name_row.text, FORMATS[format_row.selected]);
        });

        clipboard_btn.clicked.connect (() => {
            Gdk.Clipboard clipboard = Gdk.Display.get_default ().get_clipboard ();
            clipboard.changed.connect (on_clipboard_changed);
            clipboard.set_texture (Gdk.Texture.for_pixbuf (pixbuf));
        });

        retry_btn.clicked.connect (() => {
            save_response (false, folder_dir, file_name, FORMATS[format_row.selected]);
        });

        format_row.notify["selected"].connect (() => {
            settings.set_string ("format", FORMATS[format_row.selected]);
        });

        folder_button.clicked.connect (() => {
            choose_folder.begin ();
        });
    }

    private async void choose_folder () {
        var file_dialog = new Gtk.FileDialog () {
            title = _("Select Screenshots Folder…"),
            accept_label = _("Select"),
            modal = true,
            initial_folder = File.new_for_path (folder_dir)
        };

        try {
            var file = yield file_dialog.select_folder (this, null);
            if (file != null) {
                var file_path = file.get_path ();
                folder_dir = file_path;
                settings.set_string ("folder-dir", file_path);
                update_location_row (file_path);
            }
        } catch (Error e) {
            // Dismissed or failed; keep the current folder
        }
    }

    private void update_location_row (string path) {
        var file = File.new_for_path (path);
        try {
            var info = file.query_info (
                FileAttribute.STANDARD_DISPLAY_NAME + "," + FileAttribute.STANDARD_ICON,
                FileQueryInfoFlags.NONE
            );
            location_row.subtitle = info.get_display_name ();
            folder_image.gicon = info.get_icon ();
        } catch (Error e) {
            location_row.subtitle = path;
            folder_image.gicon = new ThemedIcon ("folder");
        }
    }

    private void on_clipboard_changed () {
        Gdk.Clipboard clipboard = Gdk.Display.get_default ().get_clipboard ();
        Gdk.Texture texture = Gdk.Texture.for_pixbuf (pixbuf);
        clipboard.read_texture_async.begin (null, (obj, res) => {
            try {
                Gdk.Texture? _texture = clipboard.read_texture_async.end (res);
                if (_texture != null && _texture.height == texture.height && _texture.width == texture.width) {
                    hide_destroy ();
                }
            } catch (Error e) {
                warning ("Failed to read clipboard: %s", e.message);
            }
        });
    }

    public void hide_destroy () {
        visible = false;

        // Timeout added to ensure the clipboard is synced
        // before closing the window
        GLib.Timeout.add_once (500, () => {
            close ();
        });
    }
}
