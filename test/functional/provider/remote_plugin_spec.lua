local t = require('test.testutil')
local n = require('test.functional.testnvim')()

local describe, it, before_each, teardown = t.describe, t.it, t.before_each, t.teardown
local eq, matches = t.eq, t.matches
local clear = n.clear
local command = n.command
local exec_capture = n.exec_capture
local api = n.api

local testdir = 'Xtest-rplugin'

local function update_remote_plugins(specs)
  n.run(
    function(method, args)
      eq('specs', method)
      eq(1, #args)
      return specs
    end,
    nil,
    function()
      command('call remote#host#UpdateRemotePlugins()')
      n.stop()
    end
  )
end

describe('remote plugin registration', function()
  before_each(function()
    clear()
    n.mkdir_p(testdir .. '/rplugin/busted')
    t.write_file(testdir .. '/rplugin/busted/plugin.vim', '')
    command('set runtimepath+=' .. testdir)
    command('let g:loaded_remote_plugins = "' .. testdir .. '/manifest.vim"')
    local channel = api.nvim_get_chan_info(0).id
    command('call remote#host#Register("busted", "*", {host_info -> ' .. channel .. '})')
  end)

  teardown(function()
    n.rmdir(testdir)
  end)

  it('warns when a plugin exports no handlers #4193', function()
    update_remote_plugins({})
    matches('plugin exports no handlers.*plugin%.vim', exec_capture('messages'))
  end)

  it('warns when a plugin fails to load #4193', function()
    update_remote_plugins(vim.empty_dict())
    matches('host failed to load plugin.*plugin%.vim', exec_capture('messages'))
  end)
end)
