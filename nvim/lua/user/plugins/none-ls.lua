local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

local dotnet_format = helpers.make_builtin({
    name = "dotnet_format",
    method = null_ls.methods.FORMATTING, -- Specify that this is a formatting source
    filetypes = { "cs" }, -- Apply only to C# files
    generator_opts = {
        command = "dotnet", -- The command to run
        args = { "format" }, -- Arguments for dotnet format
        to_stdin = false, -- dotnet format does not read from stdin
        ignore_stderr = true, -- Ignore stderr messages
        on_output = nil, -- No need to process the output 
        timeout = 10000,
    },
    factory = helpers.formatter_factory,
})

null_ls.setup({
    sources = {
        dotnet_format, -- Register your custom formatter
        null_ls.builtins.formatting.prettierd, -- Register prettier
        null_ls.builtins.formatting.phpcsfixer, -- Register phpcsfixer
    },
})

