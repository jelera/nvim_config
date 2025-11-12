--[[
Keymaps Unit Tests
==================

Unit tests for the core keymaps module that handles keymap registration.

Test Categories:
1. Module structure and API
2. Keymap registration
3. Default keymaps
4. Mode handling (normal, insert, visual, etc.)
5. Options handling (noremap, silent, etc.)
6. User configuration override

Uses standard luassert syntax with #unit tag.
--]]

local spec_helper = require('spec.spec_helper')

describe('modules.core.keymaps #unit', function()
  local keymaps

  before_each(function()
    spec_helper.setup()
    package.loaded['modules.core.keymaps'] = nil
    keymaps = require('modules.core.keymaps')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('module structure', function()
    it('should load keymaps module', function()
      assert.is_not_nil(keymaps)
      assert.is_table(keymaps)
    end)

    it('should have setup function', function()
      assert.is_function(keymaps.setup)
    end)

    it('should have get_defaults function', function()
      assert.is_function(keymaps.get_defaults)
    end)

    it('should have register function', function()
      assert.is_function(keymaps.register)
    end)

    it('should have register_all function', function()
      assert.is_function(keymaps.register_all)
    end)
  end)

  describe('get_defaults()', function()
    it('should return default keymaps table', function()
      local defaults = keymaps.get_defaults()
      assert.is_table(defaults)
    end)

    it('should include general keymaps', function()
      local defaults = keymaps.get_defaults()
      assert.is_not_nil(defaults.general)
      assert.is_table(defaults.general)
    end)

    it('should include window keymaps', function()
      local defaults = keymaps.get_defaults()
      assert.is_not_nil(defaults.windows)
      assert.is_table(defaults.windows)
    end)

    it('should include buffer keymaps', function()
      local defaults = keymaps.get_defaults()
      assert.is_not_nil(defaults.buffers)
      assert.is_table(defaults.buffers)
    end)

    it('should include editing keymaps', function()
      local defaults = keymaps.get_defaults()
      assert.is_not_nil(defaults.editing)
      assert.is_table(defaults.editing)
    end)
  end)

  describe('default keymaps', function()
    local defaults

    before_each(function()
      defaults = keymaps.get_defaults()
    end)

    it('should include leader key mapping for clear search', function()
      assert.is_not_nil(defaults.general['<leader><space>'])
      assert.equals(':noh<CR>', defaults.general['<leader><space>'].rhs)
    end)

    it('should include save file keymaps', function()
      assert.is_not_nil(defaults.general['<leader>w'])
      assert.equals(':w<CR>', defaults.general['<leader>w'].rhs)
    end)

    it('should include window navigation keymaps', function()
      assert.is_not_nil(defaults.windows['<C-h>'])
      assert.is_not_nil(defaults.windows['<C-j>'])
      assert.is_not_nil(defaults.windows['<C-k>'])
      assert.is_not_nil(defaults.windows['<C-l>'])
    end)

    it('should include buffer navigation keymaps', function()
      assert.is_not_nil(defaults.buffers['<S-l>'])
      assert.is_not_nil(defaults.buffers['<S-h>'])
    end)

    it('should include visual mode keymaps for indentation', function()
      assert.is_not_nil(defaults.editing['<'])
      assert.is_not_nil(defaults.editing['>'])
    end)
  end)

  describe('register()', function()
    it('should register a single keymap', function()
      local keymap_spy, spy_data = spec_helper.create_spy()
      vim.keymap.set = keymap_spy

      keymaps.register('n', '<leader>t', ':echo "test"<CR>', { desc = 'Test' })

      assert.is_true(spy_data.called)
      assert.equals(1, spy_data.call_count)
    end)

    it('should pass correct arguments to vim.keymap.set', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
      end

      keymaps.register('n', '<leader>t', ':echo "test"<CR>', { desc = 'Test', silent = true })

      assert.equals(1, #calls)
      assert.equals('n', calls[1].mode)
      assert.equals('<leader>t', calls[1].lhs)
      assert.equals(':echo "test"<CR>', calls[1].rhs)
      assert.equals('Test', calls[1].opts.desc)
      assert.is_true(calls[1].opts.silent)
    end)

    it('should handle multiple modes', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
      end

      keymaps.register({ 'n', 'v' }, '<leader>t', ':echo "test"<CR>', { desc = 'Test' })

      assert.equals(1, #calls)
      assert.is_table(calls[1].mode)
      assert.equals(2, #calls[1].mode)
    end)

    it('should apply default options', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
      end

      keymaps.register('n', '<leader>t', ':echo "test"<CR>')

      assert.equals(1, #calls)
      assert.is_true(calls[1].opts.noremap)
      assert.is_true(calls[1].opts.silent)
    end)

    it('should allow option overrides', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
      end

      keymaps.register('n', '<leader>t', ':echo "test"<CR>', { silent = false })

      assert.equals(1, #calls)
      assert.is_false(calls[1].opts.silent)
      assert.is_true(calls[1].opts.noremap)  -- Default still applies
    end)

    it('should handle function callbacks', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
      end

      local callback = function() print('test') end
      keymaps.register('n', '<leader>t', callback, { desc = 'Test' })

      assert.equals(1, #calls)
      assert.equals(callback, calls[1].rhs)
    end)

    it('should return success status', function()
      vim.keymap.set = function() end
      local success = keymaps.register('n', '<leader>t', ':echo "test"<CR>')
      assert.is_true(success)
    end)

    it('should handle errors gracefully', function()
      vim.keymap.set = function()
        error('Test error')
      end

      local success = keymaps.register('n', '<leader>t', ':echo "test"<CR>')
      assert.is_false(success)
    end)
  end)

  describe('register_all()', function()
    it('should register all keymaps from config', function()
      local call_count = 0
      vim.keymap.set = function()
        call_count = call_count + 1
      end

      local config = {
        general = {
          ['<leader>t'] = { rhs = ':echo "test"<CR>', mode = 'n', opts = { desc = 'Test' } },
          ['<leader>u'] = { rhs = ':echo "test2"<CR>', mode = 'n', opts = { desc = 'Test2' } },
        },
      }

      keymaps.register_all(config)

      assert.equals(2, call_count)
    end)

    it('should handle multiple categories', function()
      local call_count = 0
      vim.keymap.set = function()
        call_count = call_count + 1
      end

      local config = {
        general = {
          ['<leader>t'] = { rhs = ':echo "test"<CR>', mode = 'n' },
        },
        windows = {
          ['<C-h>'] = { rhs = '<C-w>h', mode = 'n' },
        },
      }

      keymaps.register_all(config)

      assert.equals(2, call_count)
    end)

    it('should use mode from keymap definition', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs })
      end

      local config = {
        general = {
          ['<leader>t'] = { rhs = ':echo "test"<CR>', mode = 'n' },
          ['<leader>v'] = { rhs = ':echo "test"<CR>', mode = 'v' },
        },
      }

      keymaps.register_all(config)

      -- Find the keymaps (order not guaranteed with pairs())
      local leader_t_mode = nil
      local leader_v_mode = nil
      for _, call in ipairs(calls) do
        if call.lhs == '<leader>t' then
          leader_t_mode = call.mode
        elseif call.lhs == '<leader>v' then
          leader_v_mode = call.mode
        end
      end

      assert.equals('n', leader_t_mode)
      assert.equals('v', leader_v_mode)
    end)

    it('should handle empty config', function()
      vim.keymap.set = function() end
      local success = keymaps.register_all({})
      assert.is_true(success)
    end)

    it('should handle nil config', function()
      vim.keymap.set = function() end
      local success = keymaps.register_all(nil)
      assert.is_true(success)
    end)

    it('should return false on error', function()
      vim.keymap.set = function()
        error('Test error')
      end

      local config = {
        general = {
          ['<leader>t'] = { rhs = ':echo "test"<CR>', mode = 'n' },
        },
      }

      local success = keymaps.register_all(config)
      assert.is_false(success)
    end)
  end)

  describe('setup()', function()
    it('should initialize with default config', function()
      vim.keymap.set = function() end
      local success = keymaps.setup()
      assert.is_true(success)
    end)

    it('should register default keymaps', function()
      local call_count = 0
      vim.keymap.set = function()
        call_count = call_count + 1
      end

      keymaps.setup()

      -- Should register keymaps from all default categories
      assert.is_true(call_count > 0)
    end)

    it('should merge user keymaps with defaults', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs })
      end

      local user_config = {
        general = {
          ['<leader>custom'] = { rhs = ':echo "custom"<CR>', mode = 'n', opts = { desc = 'Custom' } },
        },
      }

      keymaps.setup(user_config)

      -- Should have both defaults and custom keymap
      local has_custom = false
      for _, call in ipairs(calls) do
        if call.lhs == '<leader>custom' then
          has_custom = true
          break
        end
      end

      assert.is_true(has_custom)
    end)

    it('should allow user to override default keymaps', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs })
      end

      local user_config = {
        general = {
          ['<leader>w'] = { rhs = ':Wall<CR>', mode = 'n', opts = { desc = 'Save all' } },
        },
      }

      keymaps.setup(user_config)

      -- Find the <leader>w keymap
      local leader_w_count = 0
      local leader_w_rhs = nil
      for _, call in ipairs(calls) do
        if call.lhs == '<leader>w' then
          leader_w_count = leader_w_count + 1
          leader_w_rhs = call.rhs
        end
      end

      -- Should only be registered once (user override, not both)
      assert.equals(1, leader_w_count)
      assert.equals(':Wall<CR>', leader_w_rhs)
    end)

    it('should return false if setup fails', function()
      vim.keymap.set = function()
        error('Test error')
      end

      local success = keymaps.setup()
      assert.is_false(success)
    end)
  end)

  describe('keymap format', function()
    it('should accept string rhs', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { rhs = rhs })
      end

      local config = {
        general = {
          ['<leader>t'] = { rhs = ':echo "test"<CR>', mode = 'n' },
        },
      }

      keymaps.register_all(config)

      assert.equals(':echo "test"<CR>', calls[1].rhs)
    end)

    it('should accept function rhs', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { rhs = rhs })
      end

      local callback = function() print('test') end
      local config = {
        general = {
          ['<leader>t'] = { rhs = callback, mode = 'n' },
        },
      }

      keymaps.register_all(config)

      assert.equals(callback, calls[1].rhs)
    end)

    it('should preserve opts in keymap definition', function()
      local calls = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(calls, { opts = opts })
      end

      local config = {
        general = {
          ['<leader>t'] = {
            rhs = ':echo "test"<CR>',
            mode = 'n',
            opts = { desc = 'Test', buffer = 0 }
          },
        },
      }

      keymaps.register_all(config)

      assert.equals('Test', calls[1].opts.desc)
      assert.equals(0, calls[1].opts.buffer)
    end)
  end)
end)
