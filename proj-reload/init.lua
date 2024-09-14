local M = {}
local logSettings = { -- defaults
  logging = false,
  log_level = 'info',
  stop_at_cwd = true,
}

local function log(msg, level)
  if M.logSettings.logging then
    vim.notify(msg, level or M.logSettings.log_level)
  end
end

local function search_upwards(filename_pattern)
  local dir = vim.fn.expand '%:p:h'
  local cwd = vim.fn.getcwd()
  if dir == '' then
    log 'You must have a file opened'
    return
  end
  while true do
    local files = vim.fn.readdir(dir)
    for _, file in ipairs(files) do
      if file:match(filename_pattern) then
        return dir .. '/' .. file
      end
    end
    if M.logSettings.stop_at_cwd and dir == cwd then
      return nil
    end
    local parent_dir = vim.fn.fnamemodify(dir, ':h')
    if parent_dir == dir then
      return nil
    end
    dir = parent_dir
  end
end

local function canReload()
  return vim.fn.exists ':OmniSharpReloadProject' == 2
end

local function find_and_reload_asmdef()
  if not canReload() then
    log ':OmniSharpReloadProject is not available. Make sure the server is running.'
    return
  end

  local asmdef_file = search_upwards '%.asmdef$'
  if not asmdef_file then
    return
  end

  local asmdef_name = vim.fn.fnamemodify(asmdef_file, ':t:r')

  local csproj_file = search_upwards(asmdef_name .. '%.csproj$')
  if not csproj_file then
    return
  end

  vim.cmd('OmniSharpReloadProject ' .. csproj_file)
  log('Reloaded project: ' .. csproj_file)
end

M.setup = function(opts)
  M.logSettings = vim.tbl_extend('force', logSettings, opts or {})
  vim.api.nvim_create_user_command('ReloadProjectFromAsmdef', find_and_reload_asmdef, {})
end
return M
