std = "luajit"

-- hypr/ modules call the Hyprland Lua-config API; nvim/ modules run inside
-- Neovim. Neither global exists in a plain luajit std, so every file in
-- either tree would otherwise fail with "undefined global".
globals = {
    "vim",
}
read_globals = {
    "hl",
}
