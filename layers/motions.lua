local setup = require "LYRD.setup"
local mappings = require "LYRD.layers.mappings"

local L = {name = 'Motions'}

function L.plugins(s) setup.plugin(s, {'easymotion/vim-easymotion'}) end

function L.settings(s) end

function L.keybindings(s)
    -- Hides the whichkey menu for <Leader><Leader>
    mappings.leader_ignore_key(s, {','})

    mappings.keys(s, {
        {'', '<Leader><Leader>', '<Plug>(easymotion-prefix)'},
        {'', '/', '<Plug>(easymotion-sn)'},
        {'o', '/', '<Plug>(easymotion-sn)'},
        -- ➡ Jump forward
        {'', '<Plug>(easymotion-prefix)l', '<Plug>(easymotion-lineforward)'},
        -- ⬇ Jump below (Start of line)
        {'', '<Plug>(easymotion-prefix)j', '<Plug>(easymotion-sol-j)'},
        -- ⬇ Jump below
        {'', '<Plug>(easymotion-prefix)J', '<Plug>(easymotion-j)'},
        -- ⬆ Jump above (Start of line)
        {'', '<Plug>(easymotion-prefix)k', '<Plug>(easymotion-sol-k)'},
        -- ⬆ Jump above
        {'', '<Plug>(easymotion-prefix)K', '<Plug>(easymotion-k)'},
        -- ⬅ Jump backward
        {'', '<Plug>(easymotion-prefix)h', '<Plug>(easymotion-linebackward)'},
        -- Jump anywhere
        {'', '<Plug>(easymotion-prefix)a', '<Plug>(easymotion-jumptoanywhere)'},
        -- Find character (In line)
        {'', '<Plug>(easymotion-prefix)s', '<Plug>(easymotion-s)'},
        -- Search expression (In line)
        {'', '<Plug>(easymotion-prefix)S', '<Plug>(easymotion-sln)'}
    }, {noremap = false, silent = true})
end

return L
