--[[
AI Module Integration Tests - Sidekick.nvim
============================================

Integration tests for AI module using sidekick.nvim.

Sidekick.nvim provides:
- Copilot NES (Next Edit Suggestions) for multi-line refactorings
- AI CLI terminal with support for Claude, Gemini, Grok, and more

Tags: #integration #ai
--]]

describe('modules.ai #integration #ai', function()
  local spec_helper = require('spec.spec_helper')
  local ai

  before_each(function()
    spec_helper.setup()

    -- Reset module cache
    package.loaded['modules.ai'] = nil
    package.loaded['modules.ai.sidekick'] = nil
    package.loaded['modules.ai.keymaps'] = nil

    -- Reset tracking flags
    _G._test_ai_sidekick_setup_called = false
    _G._test_ai_keymaps_setup_called = false

    -- Mock submodules
    package.preload['modules.ai.sidekick'] = function()
      return {
        setup = function(config)
          _G._test_ai_sidekick_setup_called = true
          _G._test_ai_sidekick_config = config
          return true
        end,
      }
    end

    package.preload['modules.ai.keymaps'] = function()
      return {
        setup = function()
          _G._test_ai_keymaps_setup_called = true
          return true
        end,
      }
    end
  end)

  after_each(function()
    spec_helper.teardown()

    -- Clean up test globals
    _G._test_ai_sidekick_setup_called = nil
    _G._test_ai_keymaps_setup_called = nil
    _G._test_ai_sidekick_config = nil
  end)

  describe('module loading', function()
    it('should load ai module', function()
      ai = require('modules.ai')
      assert.is_table(ai)
      assert.is_function(ai.setup)
    end)

    it('should load sidekick submodule directly', function()
      package.preload['modules.ai.sidekick'] = nil
      local sidekick = require('modules.ai.sidekick')
      assert.is_table(sidekick)
      assert.is_function(sidekick.setup)
    end)

    it('should load keymaps submodule directly', function()
      package.preload['modules.ai.keymaps'] = nil
      local keymaps = require('modules.ai.keymaps')
      assert.is_table(keymaps)
      assert.is_function(keymaps.setup)
    end)
  end)

  describe('ai.setup()', function()
    it('should setup with default config', function()
      ai = require('modules.ai')
      local result = ai.setup()
      assert.is_true(result)
    end)

    it('should setup all submodules', function()
      ai = require('modules.ai')
      ai.setup()

      assert.is_true(_G._test_ai_sidekick_setup_called)
      assert.is_true(_G._test_ai_keymaps_setup_called)
    end)

    it('should setup with custom config', function()
      ai = require('modules.ai')
      local result = ai.setup({
        sidekick = {
          nes = { enabled = true },
          terminal = { enabled = true }
        }
      })
      assert.is_true(result)
    end)

    it('should pass config to sidekick', function()
      ai = require('modules.ai')
      ai.setup({
        sidekick = {
          nes = { enabled = true },
          terminal = { enabled = true, default_tool = 'claude' }
        }
      })

      assert.is_table(_G._test_ai_sidekick_config)
      assert.is_table(_G._test_ai_sidekick_config.nes)
      assert.is_true(_G._test_ai_sidekick_config.nes.enabled)
    end)

    it('should setup keymaps last', function()
      ai = require('modules.ai')
      ai.setup()

      assert.is_true(_G._test_ai_sidekick_setup_called)
      assert.is_true(_G._test_ai_keymaps_setup_called)
    end)
  end)

  describe('sidekick.setup()', function()
    it('should setup with default config', function()
      package.preload['modules.ai.sidekick'] = nil
      local sidekick = require('modules.ai.sidekick')
      local result = sidekick.setup()
      assert.is_true(result)
    end)

    it('should accept NES config', function()
      package.preload['modules.ai.sidekick'] = nil
      local sidekick = require('modules.ai.sidekick')
      local result = sidekick.setup({
        nes = {
          enabled = true,
          auto_trigger = true
        }
      })
      assert.is_true(result)
    end)

    it('should accept terminal config', function()
      package.preload['modules.ai.sidekick'] = nil
      local sidekick = require('modules.ai.sidekick')
      local result = sidekick.setup({
        terminal = {
          enabled = true,
          default_tool = 'claude'
        }
      })
      assert.is_true(result)
    end)

    it('should accept AI tools config', function()
      package.preload['modules.ai.sidekick'] = nil
      local sidekick = require('modules.ai.sidekick')
      local result = sidekick.setup({
        tools = {
          claude = { enabled = true },
          gemini = { enabled = true }
        }
      })
      assert.is_true(result)
    end)
  end)

  describe('keymaps.setup()', function()
    before_each(function()
      -- Track keymap calls
      _G._test_keymaps = {}

      -- Override vim.keymap.set
      vim.keymap = {
        set = function(mode, lhs, rhs, opts)
          table.insert(_G._test_keymaps, {
            mode = mode,
            lhs = lhs,
            rhs = rhs,
            opts = opts or {},
          })
        end,
      }
    end)

    after_each(function()
      _G._test_keymaps = nil
    end)

    it('should setup ai keymaps', function()
      package.preload['modules.ai.keymaps'] = nil
      local keymaps = require('modules.ai.keymaps')
      local result = keymaps.setup()
      assert.is_true(result)
      assert.is_true(#_G._test_keymaps > 0)
    end)

    it('should register NES keymaps', function()
      package.preload['modules.ai.keymaps'] = nil
      local keymaps = require('modules.ai.keymaps')
      keymaps.setup()

      local has_accept = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<leader>aa' or km.lhs == '<leader>an' then
          has_accept = true
          break
        end
      end

      assert.is_true(has_accept, 'Expected NES keymaps')
    end)

    it('should register terminal keymaps', function()
      package.preload['modules.ai.keymaps'] = nil
      local keymaps = require('modules.ai.keymaps')
      keymaps.setup()

      local has_terminal = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<leader>at' or km.lhs == '<leader>ac' then
          has_terminal = true
          break
        end
      end

      assert.is_true(has_terminal, 'Expected terminal keymaps')
    end)
  end)

  describe('integration', function()
    it('should setup all components together', function()
      ai = require('modules.ai')
      local result = ai.setup({
        sidekick = {
          nes = { enabled = true },
          terminal = { enabled = true, default_tool = 'claude' }
        }
      })

      assert.is_true(result)
      assert.is_true(_G._test_ai_sidekick_setup_called)
      assert.is_true(_G._test_ai_keymaps_setup_called)
    end)

    it('should work with NES only', function()
      ai = require('modules.ai')
      ai.setup({
        sidekick = {
          nes = { enabled = true },
          terminal = { enabled = false }
        }
      })

      assert.is_true(_G._test_ai_sidekick_setup_called)
    end)

    it('should work with terminal only', function()
      ai = require('modules.ai')
      ai.setup({
        sidekick = {
          nes = { enabled = false },
          terminal = { enabled = true }
        }
      })

      assert.is_true(_G._test_ai_sidekick_setup_called)
    end)
  end)
end)
