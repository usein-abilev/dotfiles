-- Programs used across modules
terminal    = "alacritty"
fileManager = "nautilus"
-- handled by scripts/super-launcher.py (evdev listener)
hyprshot    = "/usr/local/bin/hyprshot"

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "eDP-1", disabled = true })
hl.monitor({ output = "DP-1", mode = "2560x1440@120", position = "0x0", scale = 1 })

---------------------
---- ENVIRONEMNT ----
---------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
-- indirect is more stable on NVIDIA 500-series drivers
hl.env("NVD_BACKEND", "indirect")

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})

hl.permission("/usr/bin/grim", "screencopy", "allow")

-----------------
---- WINDOWS ----
-----------------
local suppressMaximizeRule = hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h - 120",
    float = true,
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "us,ru",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "grp:alt_shift_toggle",
        kb_rules     = "",

        follow_mouse = 1,

        sensitivity  = 0,

        touchpad     = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

require("autostart")
require("appearance")
require("binds")
