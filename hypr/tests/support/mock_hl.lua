-- Records every hl.* / hl.dsp.* call made while a module is required, so
-- tests can assert on exactly what a module would tell Hyprland to do.
local M = {}

local calls

local function record(name, args)
    table.insert(calls, { fn = name, args = args })
    return { fn = name, args = args }
end

local function leaf(name)
    return function(args)
        return record(name, args)
    end
end

local function handle()
    return { set_enabled = function() end }
end

local function build_dsp()
    return {
        exec_cmd = leaf("hl.dsp.exec_cmd"),
        exec_raw = leaf("hl.dsp.exec_raw"),
        focus = leaf("hl.dsp.focus"),
        layout = leaf("hl.dsp.layout"),
        window = {
            close = leaf("hl.dsp.window.close"),
            kill = leaf("hl.dsp.window.kill"),
            float = leaf("hl.dsp.window.float"),
            pseudo = leaf("hl.dsp.window.pseudo"),
            move = leaf("hl.dsp.window.move"),
            drag = leaf("hl.dsp.window.drag"),
            resize = leaf("hl.dsp.window.resize"),
        },
        workspace = {
            toggle_special = leaf("hl.dsp.workspace.toggle_special"),
            rename = leaf("hl.dsp.workspace.rename"),
        },
    }
end

local function build_hl()
    return {
        dsp = build_dsp(),
        config = function(args) return record("hl.config", args) end,
        monitor = function(args) return record("hl.monitor", args) end,
        env = function(name, value, dbus) return record("hl.env", { name = name, value = value, dbus = dbus }) end,
        permission = function(...) return record("hl.permission", { ... }) end,
        curve = function(name, spec) return record("hl.curve", { name = name, spec = spec }) end,
        animation = function(args) return record("hl.animation", args) end,
        device = function(args) return record("hl.device", args) end,
        gesture = function(args) return record("hl.gesture", args) end,
        window_rule = function(args)
            record("hl.window_rule", args)
            return handle()
        end,
        layer_rule = function(args)
            record("hl.layer_rule", args)
            return handle()
        end,
        workspace_rule = function(args) return record("hl.workspace_rule", args) end,
        exec_cmd = function(cmd, rule) return record("hl.exec_cmd", { cmd = cmd, rule = rule }) end,
        dispatch = function(d) return record("hl.dispatch", d) end,
        print = function(...) end,
        on = function(event, fn)
            record("hl.on", { event = event, fn = fn })
            return { remove = function() end, is_active = function() return true end }
        end,
        bind = function(keys, dispatcher, opts)
            record("hl.bind", { keys = keys, dispatcher = dispatcher, opts = opts })
            return handle()
        end,
        unbind = function(keys) return record("hl.unbind", keys) end,
    }
end

-- Clears recorded calls and installs a fresh global `hl` mock. Call at the
-- top of every test, before require()-ing the module under test.
function M.reset()
    calls = {}
    _G.hl = build_hl()
end

function M.calls()
    return calls
end

function M.find(fn_name)
    local matches = {}
    for _, c in ipairs(calls) do
        if c.fn == fn_name then
            table.insert(matches, c)
        end
    end
    return matches
end

function M.count(fn_name)
    return #M.find(fn_name)
end

-- require() caches modules; a module already loaded by an earlier test
-- wouldn't re-run against this test's fresh mock. Force a clean load.
function M.fresh_require(name)
    package.loaded[name] = nil
    return require(name)
end

return M
