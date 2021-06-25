local setup = require"LYRD.setup"

local L = {name = 'Mappings'}

function L.plugins(s)
  setup.plugin(s, {'liuchengxu/vim-which-key'})
end

function L.keybindings(s)
  L.keys(s, {{'n', '<Leader>', [[:WhichKey '<Leader>'<CR>]]}, {'n', '<Space>', [[:WhichKey '<Space>'<CR>]]}})
end

function L.complete(s)
  -- Updates LYRD_Settings in vim global
  local g_var = vim.g.LYRD_Settings
  g_var.mappings = s.mappings
  vim.g.LYRD_Settings = g_var
  vim.cmd("call which_key#register(',', g:LYRD_Settings.mappings.Leader)")
  vim.cmd("call which_key#register('<Space>', g:LYRD_Settings.mappings.Space)")
end

local function recursive_documentation(mapping_tree, keys, documentation, depth)
  if depth == #keys then
    mapping_tree[keys[depth]] = documentation
  else
    if mapping_tree[keys[depth]] == nil then mapping_tree[keys[depth]] = {} end
    if type(mapping_tree[keys[depth]]) ~= 'table' then
      local collapsedkeys = {}
      for i = 1, #keys do
        if i <= depth then
          table.insert(collapsedkeys, keys[i])
        else
          collapsedkeys[depth] = collapsedkeys[depth] .. keys[i]
        end
      end
      -- The next iteration would produce and error as the next node is not a dictionary
      recursive_documentation(mapping_tree, collapsedkeys, documentation, depth)
    else
      recursive_documentation(mapping_tree[keys[depth]], keys, documentation, depth + 1)
    end
  end
end

local function map_key(s, mode, lead, keys, command, documentation, options)
  if options == nil then options = {noremap = true, silent = true} end
  if lead ~= nil then
    recursive_documentation(s.mappings[lead], keys, documentation, 1)
    lead = '<' .. lead .. '>'
  else
    lead = ''
  end
  local key_str = lead .. table.concat(keys)
  vim.api.nvim_set_keymap(mode, key_str, command, options)
end

local function map_menu(s, lead, keys, description)
  recursive_documentation(s.mappings[lead], keys, {name = '[' .. description .. ']'}, 1)
end

-- Creates a set of keybindings
-- @param mappings contains the mapping definition as an array of (mode, key, command, options)
function L.keys(s, mappings, options)
  for _, mapping in ipairs(mappings) do
    local opt = mapping[4]
    if opt == nil then opt = options end
    map_key(s, mapping[1], nil, {mapping[2]}, mapping[3], nil, opt)
  end
end

-- Creates a set of keybindings starting with <Leader>
-- @param mappings contains the mapping definition as an array of (mode, {key1, key2 ...}, command, description, options)
function L.leader(s, mappings, options)
  for _, mapping in ipairs(mappings) do
    local opt = mapping[5]
    if opt == nil then opt = options end
    map_key(s, mapping[1], 'Leader', mapping[2], mapping[3], mapping[4], opt)
  end
end

-- Creates a set of keybindings starting with <Space>
-- @param mappings contains the mapping definition as an array of (mode, {key1, key2 ...}, command, description, options)
function L.space(s, mappings, options)
  for _, mapping in ipairs(mappings) do
    local opt = mapping[5]
    if opt == nil then opt = options end
    map_key(s, mapping[1], 'Space', mapping[2], mapping[3], mapping[4], opt)
  end
end

-- Creates a cascading menu for a sequence of keys starting with <Space>
-- @param mappings contains the mapping definition as an array of ({key1, key2 ...}, description)
function L.space_menu(s, mappings)
  for _, mapping in ipairs(mappings) do map_menu(s, 'Space', mapping[1], mapping[2]) end
end

-- Causes a sequence of keys starting with <Space> to be ignored and to nod appear in the menu
-- @param keys is an array of keys to be ignored in the menu
function L.leader_ignore_key(s, keys)
  recursive_documentation(s.mappings['Leader'], keys, 'which_key_ignore', 1)
end

-- Causes a sequence of keys starting with <Space> to be ignored and to nod appear in the menu
-- @param keys is an array of keys to be ignored in the menu
function L.leader_ignore_menu(s, keys)
  recursive_documentation(s.mappings['Leader'], keys, {name = 'which_key_ignore'}, 1)
end

local function map_shared_expression(s, key, layer, expression)
  s.SharedExpressions[key][layer] = expression
end

local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function get_shared_expression(s, key, default)
  local evaluation_order = {'completion', 'snippets'}
  for _, layer in ipairs(evaluation_order) do
    local expression_fn = s.SharedExpressions[key][layer]
    if expression_fn ~= nil then
      local expression = expression_fn()
      if expression ~= nil then
        return expression
      end
    end
  end
  return t(default)
end

function L.map_tab_expression(s, layer, expression)
  map_shared_expression(s, 'Tab', layer, expression)
end

function L.map_shift_tab_expression(s, layer, expression)
  map_shared_expression(s, 'Shift_Tab', layer, expression)
end

function L.map_enter_expression(s, layer, expression)
  map_shared_expression(s, 'Enter', layer, expression)
end

function L.settings(s)
  s.mappings = {Leader = {}, Space = {}}
  s.SharedExpressions = {Tab = {}, Shift_Tab = {}, Enter = {}}
  vim.g.which_key_timeout = 100
  _G.LYRD_TabExpression = function()
    return get_shared_expression(s, 'Tab', '<Tab>')
  end
  _G.LYRD_ShiftTabExpression = function()
    return get_shared_expression(s, 'Shift_Tab', '<S-Tab>')
  end
  _G.LYRD_EnterExpression = function()
    return get_shared_expression(s, 'Enter', '<CR>')
  end
end

return L
