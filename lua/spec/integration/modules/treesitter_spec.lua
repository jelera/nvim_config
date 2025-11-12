--[[
TreeSitter Module Integration Tests
====================================

Integration tests for TreeSitter module with vim options and configurations.

Test Categories:
1. Full setup workflow
2. Vim folding configuration
3. Integration with multiple modules
--]]

describe('modules.treesitter #integration', function()
  local spec_helper = require('spec.spec_helper')
  local treesitter

  before_each(function()
    spec_helper.setup()

    -- Reset module cache
    package.loaded['modules.treesitter'] = nil
    package.loaded['modules.treesitter.init'] = nil
    package.loaded['nvim-treesitter.configs'] = nil

    -- Track configuration
    _G._test_treesitter_config = nil
    _G._test_vim_options = {}

    -- Mock nvim-treesitter.configs
    package.preload['nvim-treesitter.configs'] = function()
      return {
        setup = function(config)
          _G._test_treesitter_config = config
        end,
      }
    end

    -- Mock vim.opt to track folding options
    vim.opt = setmetatable({}, {
      __newindex = function(_, key, value)
        _G._test_vim_options[key] = value
      end,
      __index = function(_, key)
        return _G._test_vim_options[key]
      end,
    })

    treesitter = require('modules.treesitter')
  end)

  after_each(function()
    spec_helper.teardown()
    _G._test_treesitter_config = nil
    _G._test_vim_options = nil
  end)

  describe('Full setup workflow', function()
    it('should complete full setup successfully', function()
      local result = treesitter.setup()

      assert.is_true(result)
      assert.is_not_nil(_G._test_treesitter_config)
    end)

    it('should configure all major features', function()
      treesitter.setup()

      local config = _G._test_treesitter_config

      -- Verify all major features are configured
      assert.is_not_nil(config.highlight)
      assert.is_not_nil(config.indent)
      assert.is_not_nil(config.incremental_selection)
      assert.is_not_nil(config.textobjects)
    end)

    it('should handle custom config override', function()
      treesitter.setup({
        highlight = {
          enable = false,
          additional_vim_regex_highlighting = true,
        },
      })

      local config = _G._test_treesitter_config

      assert.is_false(config.highlight.enable)
      assert.is_true(config.highlight.additional_vim_regex_highlighting)
      -- Other features should still be present
      assert.is_not_nil(config.indent)
      assert.is_not_nil(config.textobjects)
    end)
  end)

  describe('Vim folding configuration', function()
    it('should set foldmethod to expr', function()
      treesitter.setup()
      assert.equal('expr', _G._test_vim_options.foldmethod)
    end)

    it('should set foldexpr to nvim_treesitter#foldexpr()', function()
      treesitter.setup()
      assert.equal('nvim_treesitter#foldexpr()', _G._test_vim_options.foldexpr)
    end)

    it('should disable folding by default', function()
      treesitter.setup()
      assert.is_false(_G._test_vim_options.foldenable)
    end)

    it('should set folding options after TreeSitter config', function()
      local setup_order = {}

      package.loaded['nvim-treesitter.configs'] = nil
      package.preload['nvim-treesitter.configs'] = function()
        return {
          setup = function(config)
            table.insert(setup_order, 'treesitter')
            _G._test_treesitter_config = config
          end,
        }
      end

      vim.opt = setmetatable({}, {
        __newindex = function(_, key, value)
          if key == 'foldmethod' or key == 'foldexpr' or key == 'foldenable' then
            table.insert(setup_order, 'fold:' .. key)
          end
          _G._test_vim_options[key] = value
        end,
      })

      treesitter.setup()

      -- TreeSitter should be configured first, then folding
      assert.equal('treesitter', setup_order[1])
      assert.is_not_nil(setup_order[2]:match('^fold:'))
    end)
  end)

  describe('Text objects configuration', function()
    it('should configure all text object select keymaps', function()
      treesitter.setup()

      local select_keymaps = _G._test_treesitter_config.textobjects.select.keymaps

      -- Verify key textobj keymaps exist
      assert.is_not_nil(select_keymaps['af']) -- function outer
      assert.is_not_nil(select_keymaps['if']) -- function inner
      assert.is_not_nil(select_keymaps['ac']) -- class outer
      assert.is_not_nil(select_keymaps['ic']) -- class inner
    end)

    it('should configure move keymaps', function()
      treesitter.setup()

      local move = _G._test_treesitter_config.textobjects.move

      assert.is_not_nil(move.goto_next_start)
      assert.is_not_nil(move.goto_previous_start)
      assert.is_not_nil(move.goto_next_start[']m'])
      assert.is_not_nil(move.goto_previous_start['[m'])
    end)

    it('should configure swap keymaps', function()
      treesitter.setup()

      local swap = _G._test_treesitter_config.textobjects.swap

      assert.is_true(swap.enable)
      assert.is_not_nil(swap.swap_next)
      assert.is_not_nil(swap.swap_previous)
    end)

    it('should enable lookahead for text objects', function()
      treesitter.setup()

      assert.is_true(_G._test_treesitter_config.textobjects.select.lookahead)
    end)
  end)

  describe('Incremental selection configuration', function()
    it('should configure all incremental selection keymaps', function()
      treesitter.setup()

      local keymaps = _G._test_treesitter_config.incremental_selection.keymaps

      assert.is_not_nil(keymaps.init_selection)
      assert.is_not_nil(keymaps.node_incremental)
      assert.is_not_nil(keymaps.scope_incremental)
      assert.is_not_nil(keymaps.node_decremental)
    end)
  end)

  describe('Parser installation', function()
    it('should auto-install all parsers by default', function()
      treesitter.setup()

      assert.equal('all', _G._test_treesitter_config.ensure_installed)
      assert.is_true(_G._test_treesitter_config.auto_install)
    end)

    it('should respect custom parser list', function()
      treesitter.setup({
        ensure_installed = { 'lua', 'python', 'javascript' },
      })

      local parsers = _G._test_treesitter_config.ensure_installed
      assert.is_table(parsers)
      assert.equal(3, #parsers)
    end)

    it('should allow disabling auto_install', function()
      treesitter.setup({
        auto_install = false,
      })

      assert.is_false(_G._test_treesitter_config.auto_install)
    end)
  end)

  describe('Integration with other modules', function()
    it('should work after UI module setup', function()
      -- Simulate UI module being loaded first
      package.loaded['modules.ui'] = { setup = function() return true end }

      local result = treesitter.setup()
      assert.is_true(result)
    end)

    it('should be idempotent - multiple setups should work', function()
      treesitter.setup()
      local result = treesitter.setup({ highlight = { enable = false } })

      assert.is_true(result)
      assert.is_false(_G._test_treesitter_config.highlight.enable)
    end)
  end)

  describe('Error handling', function()
    it('should gracefully handle TreeSitter setup errors', function()
      package.loaded['nvim-treesitter.configs'] = nil
      package.preload['nvim-treesitter.configs'] = function()
        return {
          setup = function()
            error('TreeSitter configuration failed')
          end,
        }
      end

      local result = treesitter.setup()

      assert.is_false(result)
      -- Folding options should not be set if setup failed
      assert.is_nil(_G._test_vim_options.foldmethod)
    end)
  end)
end)
