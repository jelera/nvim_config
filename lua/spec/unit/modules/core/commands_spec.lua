--[[
Commands Unit Tests
===================

Unit tests for the core commands module that handles user command registration.

Test Categories:
1. Module structure and API
2. Command registration
3. Default commands
4. Command options (bang, range, nargs, etc.)
5. User configuration override

Uses standard luassert syntax with #unit tag.
--]]

local spec_helper = require('spec.spec_helper')

describe('modules.core.commands #unit', function()
  local commands

  before_each(function()
    spec_helper.setup()
    package.loaded['modules.core.commands'] = nil
    commands = require('modules.core.commands')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('module structure', function()
    it('should load commands module', function()
      assert.is_not_nil(commands)
      assert.is_table(commands)
    end)

    it('should have setup function', function()
      assert.is_function(commands.setup)
    end)

    it('should have get_defaults function', function()
      assert.is_function(commands.get_defaults)
    end)

    it('should have register function', function()
      assert.is_function(commands.register)
    end)

    it('should have register_all function', function()
      assert.is_function(commands.register_all)
    end)
  end)

  describe('get_defaults()', function()
    it('should return default commands table', function()
      local defaults = commands.get_defaults()
      assert.is_table(defaults)
    end)

    it('should include format command', function()
      local defaults = commands.get_defaults()
      assert.is_not_nil(defaults.Format)
    end)

    it('should include buf delete command', function()
      local defaults = commands.get_defaults()
      assert.is_not_nil(defaults.BufDelete)
    end)
  end)

  describe('default commands', function()
    local defaults

    before_each(function()
      defaults = commands.get_defaults()
    end)

    it('should have Format command with function callback', function()
      assert.is_not_nil(defaults.Format)
      assert.is_function(defaults.Format.callback)
    end)

    it('should have BufDelete command', function()
      assert.is_not_nil(defaults.BufDelete)
    end)

    it('should have ReloadConfig command', function()
      assert.is_not_nil(defaults.ReloadConfig)
    end)
  end)

  describe('register()', function()
    it('should register a command', function()
      local cmd_spy, spy_data = spec_helper.create_spy()
      vim.api.nvim_create_user_command = cmd_spy

      commands.register('TestCommand', function() end, {})

      assert.is_true(spy_data.called)
      assert.equals(1, spy_data.call_count)
    end)

    it('should pass correct arguments', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { name = name, callback = callback, opts = opts })
      end

      local test_callback = function() print('test') end
      commands.register('TestCommand', test_callback, { desc = 'Test command' })

      assert.equals(1, #calls)
      assert.equals('TestCommand', calls[1].name)
      assert.equals(test_callback, calls[1].callback)
      assert.equals('Test command', calls[1].opts.desc)
    end)

    it('should handle string callbacks', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { name = name, callback = callback })
      end

      commands.register('TestCommand', ':echo "test"', {})

      assert.equals(1, #calls)
      assert.equals(':echo "test"', calls[1].callback)
    end)

    it('should handle function callbacks', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { name = name, callback = callback })
      end

      local test_fn = function() print('test') end
      commands.register('TestCommand', test_fn, {})

      assert.equals(1, #calls)
      assert.equals(test_fn, calls[1].callback)
    end)

    it('should apply default options', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { opts = opts })
      end

      commands.register('TestCommand', function() end)

      assert.equals(1, #calls)
      -- No specific default opts currently, just checking it doesn't error
      assert.is_table(calls[1].opts)
    end)

    it('should allow option overrides', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { opts = opts })
      end

      commands.register('TestCommand', function() end, {
        bang = true,
        range = true,
        nargs = '*',
        desc = 'Test',
      })

      assert.is_true(calls[1].opts.bang)
      assert.is_true(calls[1].opts.range)
      assert.equals('*', calls[1].opts.nargs)
      assert.equals('Test', calls[1].opts.desc)
    end)

    it('should return success status', function()
      vim.api.nvim_create_user_command = function() end
      local success = commands.register('TestCommand', function() end)
      assert.is_true(success)
    end)

    it('should handle errors gracefully', function()
      vim.api.nvim_create_user_command = function()
        error('Test error')
      end

      local success = commands.register('TestCommand', function() end)
      assert.is_false(success)
    end)
  end)

  describe('register_all()', function()
    it('should register all commands from config', function()
      local call_count = 0
      vim.api.nvim_create_user_command = function()
        call_count = call_count + 1
      end

      local config = {
        TestCommand1 = { callback = function() end, opts = {} },
        TestCommand2 = { callback = function() end, opts = {} },
      }

      commands.register_all(config)

      assert.equals(2, call_count)
    end)

    it('should pass callback and opts correctly', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { name = name, callback = callback, opts = opts })
      end

      local cb1 = function() print('1') end
      local cb2 = function() print('2') end

      local config = {
        Cmd1 = { callback = cb1, opts = { desc = 'Command 1' } },
        Cmd2 = { callback = cb2, opts = { desc = 'Command 2' } },
      }

      commands.register_all(config)

      -- Find commands (order not guaranteed)
      local cmd1_data = nil
      local cmd2_data = nil
      for _, call in ipairs(calls) do
        if call.name == 'Cmd1' then
          cmd1_data = call
        elseif call.name == 'Cmd2' then
          cmd2_data = call
        end
      end

      assert.is_not_nil(cmd1_data)
      assert.is_not_nil(cmd2_data)
      assert.equals(cb1, cmd1_data.callback)
      assert.equals(cb2, cmd2_data.callback)
      assert.equals('Command 1', cmd1_data.opts.desc)
      assert.equals('Command 2', cmd2_data.opts.desc)
    end)

    it('should handle empty config', function()
      vim.api.nvim_create_user_command = function() end
      local success = commands.register_all({})
      assert.is_true(success)
    end)

    it('should handle nil config', function()
      vim.api.nvim_create_user_command = function() end
      local success = commands.register_all(nil)
      assert.is_true(success)
    end)

    it('should return false on error', function()
      vim.api.nvim_create_user_command = function()
        error('Test error')
      end

      local config = {
        TestCommand = { callback = function() end, opts = {} },
      }

      local success = commands.register_all(config)
      assert.is_false(success)
    end)
  end)

  describe('setup()', function()
    it('should initialize with default config', function()
      vim.api.nvim_create_user_command = function() end
      local success = commands.setup()
      assert.is_true(success)
    end)

    it('should register default commands', function()
      local call_count = 0
      vim.api.nvim_create_user_command = function()
        call_count = call_count + 1
      end

      commands.setup()

      -- Should register some default commands
      assert.is_true(call_count > 0)
    end)

    it('should merge user commands with defaults', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { name = name })
      end

      local user_config = {
        CustomCommand = { callback = function() end, opts = { desc = 'Custom' } },
      }

      commands.setup(user_config)

      -- Should have custom command
      local has_custom = false
      for _, call in ipairs(calls) do
        if call.name == 'CustomCommand' then
          has_custom = true
          break
        end
      end

      assert.is_true(has_custom)
    end)

    it('should allow user to override default commands', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { name = name, callback = callback })
      end

      local custom_callback = function() print('custom') end
      local user_config = {
        Format = { callback = custom_callback, opts = { desc = 'Custom format' } },
      }

      commands.setup(user_config)

      -- Find the Format command
      local format_count = 0
      local format_callback = nil
      for _, call in ipairs(calls) do
        if call.name == 'Format' then
          format_count = format_count + 1
          format_callback = call.callback
        end
      end

      -- Should only be registered once (user override)
      assert.equals(1, format_count)
      assert.equals(custom_callback, format_callback)
    end)

    it('should return false if setup fails', function()
      vim.api.nvim_create_user_command = function()
        error('Test error')
      end

      local success = commands.setup()
      assert.is_false(success)
    end)
  end)

  describe('command options', function()
    it('should support bang option', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { opts = opts })
      end

      commands.register('TestCommand', function() end, { bang = true })

      assert.is_true(calls[1].opts.bang)
    end)

    it('should support range option', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { opts = opts })
      end

      commands.register('TestCommand', function() end, { range = true })

      assert.is_true(calls[1].opts.range)
    end)

    it('should support nargs option', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { opts = opts })
      end

      commands.register('TestCommand', function() end, { nargs = '*' })

      assert.equals('*', calls[1].opts.nargs)
    end)

    it('should support desc option', function()
      local calls = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        table.insert(calls, { opts = opts })
      end

      commands.register('TestCommand', function() end, { desc = 'Test description' })

      assert.equals('Test description', calls[1].opts.desc)
    end)
  end)
end)
