# egui template

A starting point for writing an application that runs natively on desktop and in the browser using WASM.

I extracted this from a larger project I've been working on since I wanted an
easier starting point when working on smaller projects. I made it a template
rather than a library so it's a starting point to modify, rather than
something to build on top of.

See it live: https://www.omustardo.com/share/app_template/

## What you get

* UI made with http://egui.rs. Support for resizeable and movable panels
* Saving and loading of state, on both desktop and web. Export and import from clipboard is also supported
* Saving and loading of UI layout
* `make run` and `make web` for locally running on desktop and wasm
* `make tidy` runs formatting and LICENSE file generation
* `make licenses-check` uses `deny.toml` to ensure that you only depend on code that is licensed in ways that you want
* Menu bar
* A tick-based update system, intended for making games
* A logging library

The code is meant to be modifiable, so any of these should be straightforward to remove if they aren't needed for your project.

## Build and Run

### Native

Run:
```shell
make run
```

Build (release):
```shell
make build-release-native

# The generated binary is:
./target/release/app
```

### Web

Run:
```shell
make web

# View it at: http://localhost:50051/index.html#dev
# "#dev" prevents caching.
```

Build:
```shell
make build-release-wasm

# The generated files are in:
./src/crates/app/dist/
# You can serve them locally with:
python3 -m http.server 8000 -d ./src/crates/app/dist/
# Or package them up and put them in a static HTTP server.
```

Building for web will output a `index.html` file, and other files to be served
alongside it. It assumes that it will be served at the root URL of your website.
If you want to use a different URL, modify the `build-release-wasm` section
of the `Makefile`. There is more detail in the comments there.

## Branching this template

1. If you are making a private personal project, you may remove LICENSES, and
the license related sections of the Makefile. Otherwise you may want to update
`deny.toml` to reflect the types of licenses you are okay with your project
depending on.

2. Install the necessary tools listed at the top of the `Makefile`.

3. Replace or delete `REPO_SSH_URL` and the following "push" command from `Makefile`.

4. If you want to build for web, modify the "--public-url" parameter in the Makefile. See the comment around it for more detail.

5. If you are okay with your app being named "My App", then skip this step.
Otherwise search for all instances of TEMPLATE_TODO and update what asks to update.
This is mostly changing things like my_app to your app's name.
Follow the existing pattern in each case (e.g. if you're replacing my_app, use lowercase and underscores).

6. If desired, fonts and icons can be modified in src/crates/app/assets/

## Content

```shell
.
├── LICENSES # Use `make tidy` or `make licenses`
├── Makefile
├── README.md
└── src/
    ├── Cargo.lock
    ├── Cargo.toml
    ├── crates/
    │     └── app/  # The main binary's crate
    │         ├── assets/ # Static assets like fonts and icons
    │         ├── Cargo.toml # Rust config for the app crate
    │         ├── index.html # Static page to display the WASM build
    │         └── src/
    │             ├── app.rs # App state is defined here
    │             ├── lib.rs
    │             ├── log_categories.rs
    │             ├── main.rs
    │             ├── menus/ # The menu bar and menus. These can modify app state.
    │             │     ├── about_menu.rs
    │             │     ├── debug_menu/
    │             │     │     ├── debug.rs
    │             │     │     └── mod.rs
    │             │     ├── main_menu/
    │             │     │     ├── dialogs.rs
    │             │     │     ├── file_menu.rs
    │             │     │     ├── mod.rs
    │             │     │     └── save_operations.rs
    │             │     ├── mod.rs
    │             │     └── settings_menu/
    │             │         ├── dock_settings.rs
    │             │         ├── layout_menu/
    │             │         │     ├── layout.rs
    │             │         │     ├── mod.rs
    │             │         │     └── name_generator.rs
    │             │         ├── mod.rs
    │             │         └── settings.rs
    │             ├── misc/
    │             │     ├── fonts.rs
    │             │     ├── fps_counter.rs
    │             │     ├── keyboard_shortcuts.rs
    │             │     └── mod.rs
    │             ├── tabs/ # Except for the menu bar, everything is shown within tabs.
    │             │     ├── command.rs
    │             │     ├── layout_presets.rs
    │             │     ├── mod.rs
    │             │     ├── my_tab_viewer.rs
    │             │     └── render/
    │             │         ├── center_panel.rs
    │             │         ├── left_panel.rs
    │             │         ├── mod.rs
    │             │         └── right_panel.rs
    │             └── tick.rs
    ├── deny.toml
    └── rustfmt.toml
```