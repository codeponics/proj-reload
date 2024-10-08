# proj-reload

**Note: well, looks like I just found out :OmniSharpReloadProject already does what this plugin does. Just use that instead for one-time .csproj reload. There are a few bugs still present even when doing :OmniSharpReloadProject which I aim to fix in th future with this plugin.**

If you are looking to set up Unity with Neovim, I recommend downloading omnisharp-vim, ale, and asyncomplete or coc.nvim. Check :OmniSharpStatus as you are waiting for it to load OmniSharp in your file. When it is done loading, now this plugin can be of interest to you.

This is a lightweight (69 lines) neovim lua plugin. With the lack of Unity neovim support, I aim to make development a little easier for omnisharp-vim Unity users with this plugin.

## Purpose

Reload .csproj file associated with the .asmdef from the working directory of the file you are writing C# code in.

Suppose you work on your Unity project and add a new .cs file while your omnisharp server is running. You have to now go into Unity, regenerate project files, then either restart the server to re-process all .csproj files (not worth the extra 1-2 minutes of your time) or manually reload the .csproj associated with the closest .asmdef (only one) to your new .cs file. The latter method can take less than 2 seconds and it doesn't matter how many new .cs files are made.

This plugin allows you to quickly call the :OmniSharpReloadProject command on the relevant .csproj file, instantly granting you autocompletion in the current buffer file without manual hassle. You would call the command `:ReloadProjectFromAsmdef`

The command does not produce error messages, but simply logs messages in case you don't have :OmniSharpReloadProject available or a file is not opened. "file opened" means the current buffer is on a file that has a path.

Note: do not call the command without first ensuring your OmniSharp server is first loaded to prevent an error. (Use :OmniSharpStatus if you are not sure at any time)

## When to refresh?

This may look like common sense but it is just to give you an idea of the exact cases to refresh rather than when not to.

| Case                                                      | Refresh (`✓`) / No Refresh (`✗`) |
|------------------------------------------------------------|----------------------------------|
| File content changes                                       | ✗                                |
| File name changes                                          | ✓                                |
| File moved but in the same `.asmdef`                       | ✗                                |
| File moved and associated with a different `.asmdef`       | ✓                                |
| File deleted                                               | ✓                                |
| File added                                                 | ✓                                |
| File extension changes                                     | ✓                                |
| Folder structure changes                                   | ✓                                |
| `.asmdef` file changes                                     | ✓                                |
| Changes made by version control                            | ✓                                |

## Installation
Each code snippet uses default settings that looks like this:
```lua
{
    logging = false,   
    log_level = 'info',
    stop_at_cwd = true 
}
```
You can pass a modified version of this table to .setup() if you would like to easily modify those settings.

For lazy.nvim users, add a lua file in the directory of your stored remote plugins (custom/plugins for example) and insert the code:
```lua
return {
  'codeponics/proj-reload',
  config = function()
    require('proj-reload').setup()
  end,
}
```

For packer.nvim users, change return to use with the above code snippet.

For vim-plug:
```
Plug 'codeponics/proj-reload'

lua << EOF
require('proj-reload').setup()
EOF
```

Example keybinding in lua (can paste into config function or after lazy setup in init.lua):
```lua
vim.api.nvim_set_keymap('n', '<leader>r', '<Cmd>ReloadProjectFromAsmdef<CR>', { noremap = true, silent = true })
```

## Plans
* .asmdef tracking when new files are created and easily reload more than 1 .csproj file as needed rather than manually and slowly using the command on all files you wish to reload. This would be a toggleable option.
* Add project file regeneration in some way when there is no existing Unity process
(Unfortunately as Unity only allows one instance, it is not possible to regenerate project files when Unity is opened. I will research how to overcome this but it may be hacky.)
* Detect changes caused by Git or Perforce to refresh automatically based on diff
* Extra command that refreshes all .csproj from all .asmdef found up to working directory (to refresh user-made .csproj and avoid refreshing Unity's .csproj redundantly for example)

I have no intention to support omnisharp-roslyn soon but I may change my mind someday. I have no other plans in order to keep this a lightweight plugin. Feel free to suggest if it benefits your use case.
