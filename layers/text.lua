local setup = require("LYRD.setup")

local L = { name = "Text functions" }

function L.plugins()
    setup.plugin({
        {
            "johmsalas/text-case.nvim",
            dependencies = { "nvim-telescope/telescope.nvim" },
            opts = {},
            config = function(_, opts)
                require("textcase").setup(opts)
                require("telescope").load_extension("textcase")
            end,
            keys = {
                "ga", -- Default invocation prefix
                { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
            },
            cmd = {
                -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
                "Subs",
                "TextCaseOpenTelescope",
                "TextCaseOpenTelescopeQuickChange",
                "TextCaseOpenTelescopeLSPChange",
                "TextCaseStartReplacingCommand",
            },
            -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
            -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
            -- available after the first executing of it or after a keymap of text-case.nvim has been used.
            lazy = false,
        },
    })
end

function L.to_title_case(text_input)
    return require("textcase").api.to_title_case(text_input)
end

function L.to_upper_case(text_input)
    return require("textcase").api.to_upper_case(text_input)
end

function L.to_lower_case(text_input)
    return require("textcase").api.to_lower_case(text_input)
end

function L.to_capital_snake_case(text_input)
    return require("textcase").api.to_constant_case(text_input)
end

function L.to_snake_case(text_input)
    return require("textcase").api.to_snake_case(text_input)
end

function L.to_dash_case(text_input)
    return require("textcase").api.to_dash_case(text_input)
end

function L.to_camel_case(text_input)
    return require("textcase").api.to_camel_case(text_input)
end

function L.to_pascal_case(text_input)
    return require("textcase").api.to_pascal_case(text_input)
end

return L
