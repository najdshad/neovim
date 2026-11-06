local group = vim.api.nvim_create_augroup('nvim.editorconfig', {})
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufFilePost', 'FileType' }, {
  group = group,
  callback = function(ev)
    -- FileType fires before the initial BufRead. Only reapply after EditorConfig
    -- has run once, e.g. when an ftplugin is re-triggered.
    if ev.event == 'FileType' and vim.b[ev.buf].editorconfig == nil then
      return
    end

    -- Buffer-local enable has higher priority
    local enable = vim.nonnil(vim.b.editorconfig, vim.g.editorconfig, true)
    if not enable then
      return
    end

    require('editorconfig').config(ev.buf)
  end,
})
