--[[
Completion Module Unit Tests
=============================

Unit tests for nvim-cmp completion configuration.
--]]

describe('modules.completion.completion #unit', function()
  local spec_helper = require('spec.spec_helper')
  local completion

  before_each(function()
    spec_helper.setup()

    -- Reset module cache (MUST clear before setting up mocks)
    package.loaded['modules.completion.completion'] = nil
    package.loaded['modules.completion.snippets'] = nil
    package.loaded['cmp'] = nil
    package.loaded['cmp_nvim_lsp'] = nil
    package.loaded['cmp_buffer'] = nil
    package.loaded['cmp_path'] = nil
    package.loaded['cmp_cmdline'] = nil
    package.loaded['cmp_luasnip'] = nil
    package.loaded['luasnip'] = nil

    -- Track cmp setup
    _G._test_cmp_setup_called = false
    _G._test_cmp_config = nil
    _G._test_keymaps = {}
    _G._test_cmdline_setup = {}

    -- Mock LuaSnip (needed by snippets module)
    package.preload['luasnip'] = function()
      return {
        lsp_expand = function(body) return 'expanded: ' .. body end,
      }
    end

    -- Mock snippets module
    package.preload['modules.completion.snippets'] = function()
      return {
        get_luasnip = function()
          return require('luasnip')
        end,
      }
    end

    -- Mock nvim-cmp
    package.preload['cmp'] = function()
      -- Create mapping object that is both callable and has properties
      local mapping_obj = {
        complete = function()
          return 'complete_mapping'
        end,
        abort = function()
          return 'abort_mapping'
        end,
        confirm = function(opts)
          return 'confirm_mapping'
        end,
        select_next_item = function()
          return 'select_next_mapping'
        end,
        select_prev_item = function()
          return 'select_prev_mapping'
        end,
        preset = {
          insert = function(mappings)
            return mappings
          end,
          cmdline = function(mappings)
            return mappings or {}
          end,
        },
      }

      -- Make mapping callable as a function
      setmetatable(mapping_obj, {
        __call = function(_, func_or_mapping, modes)
          return function(fallback)
            if type(func_or_mapping) == 'function' then
              return func_or_mapping(fallback)
            else
              return func_or_mapping
            end
          end
        end,
      })

      return {
        setup = function(config)
          _G._test_cmp_setup_called = true
          _G._test_cmp_config = config
        end,
        setup_cmdline = function(mode, config)
          table.insert(_G._test_cmdline_setup, { mode = mode, config = config })
        end,
        mapping = mapping_obj,
        visible = function()
          return false
        end,
        config = {
          sources = function(group1, group2)
            -- Flatten all source groups into one list
            local all_sources = {}
            if group1 then
              for _, source in ipairs(group1) do
                table.insert(all_sources, source)
              end
            end
            if group2 then
              for _, source in ipairs(group2) do
                table.insert(all_sources, source)
              end
            end
            return all_sources
          end,
        },
        SelectBehavior = {
          Select = 'select',
        },
        ConfirmBehavior = {
          Replace = 'replace',
        },
      }
    end

    -- Mock completion sources
    package.preload['cmp_nvim_lsp'] = function()
      return {}
    end
    package.preload['cmp_buffer'] = function()
      return {}
    end
    package.preload['cmp_path'] = function()
      return {}
    end
    package.preload['cmp_cmdline'] = function()
      return {}
    end

    -- Mock luasnip for cmp_luasnip
    package.preload['cmp_luasnip'] = function()
      return {}
    end

    completion = require('modules.completion.completion')
  end)

  after_each(function()
    spec_helper.teardown()
    _G._test_cmp_setup_called = nil
    _G._test_cmp_config = nil
    _G._test_keymaps = nil
    _G._test_cmdline_setup = nil

    -- Clear package cache AND preload to prevent test interference
    package.loaded['modules.completion.completion'] = nil
    package.loaded['modules.completion.snippets'] = nil
    package.loaded['cmp'] = nil
    package.loaded['cmp_nvim_lsp'] = nil
    package.loaded['cmp_buffer'] = nil
    package.loaded['cmp_path'] = nil
    package.loaded['cmp_cmdline'] = nil
    package.loaded['cmp_luasnip'] = nil
    package.loaded['luasnip'] = nil

    package.preload['cmp'] = nil
    package.preload['cmp_nvim_lsp'] = nil
    package.preload['cmp_buffer'] = nil
    package.preload['cmp_path'] = nil
    package.preload['cmp_cmdline'] = nil
    package.preload['cmp_luasnip'] = nil
    package.preload['luasnip'] = nil
    package.preload['modules.completion.snippets'] = nil
  end)

  describe('Module structure', function()
    it('should have a setup function', function()
      assert.is_function(completion.setup)
    end)
  end)

  describe('setup()', function()
    it('should return true on successful setup', function()
      local result = completion.setup()
      assert.is_true(result)
    end)

    it('should call cmp.setup', function()
      completion.setup()
      assert.is_true(_G._test_cmp_setup_called)
    end)

    it('should accept empty config', function()
      local result = completion.setup({})
      assert.is_true(result)
    end)

    it('should accept nil config', function()
      local result = completion.setup(nil)
      assert.is_true(result)
    end)
  end)

  describe('Completion sources', function()
    it('should configure completion sources', function()
      completion.setup()
      assert.is_not_nil(_G._test_cmp_config)
      assert.is_not_nil(_G._test_cmp_config.sources)
    end)

    it('should include LSP source', function()
      completion.setup()
      local sources = _G._test_cmp_config.sources
      local has_lsp = false
      for _, source in ipairs(sources) do
        if source.name == 'nvim_lsp' then
          has_lsp = true
          break
        end
      end
      assert.is_true(has_lsp)
    end)

    it('should include snippet source', function()
      completion.setup()
      local sources = _G._test_cmp_config.sources
      local has_snippet = false
      for _, source in ipairs(sources) do
        if source.name == 'luasnip' then
          has_snippet = true
          break
        end
      end
      assert.is_true(has_snippet)
    end)

    it('should include buffer and path sources', function()
      completion.setup()
      local sources = _G._test_cmp_config.sources
      local has_buffer = false
      local has_path = false
      for _, source in ipairs(sources) do
        if source.name == 'buffer' then
          has_buffer = true
        end
        if source.name == 'path' then
          has_path = true
        end
      end
      assert.is_true(has_buffer)
      assert.is_true(has_path)
    end)
  end)

  describe('Completion behavior', function()
    it('should configure snippet expansion', function()
      completion.setup()
      assert.is_not_nil(_G._test_cmp_config.snippet)
      assert.is_function(_G._test_cmp_config.snippet.expand)
    end)

    it('should configure completion behavior', function()
      completion.setup()
      assert.is_not_nil(_G._test_cmp_config.completion)
    end)

    it('should configure mapping', function()
      completion.setup()
      assert.is_not_nil(_G._test_cmp_config.mapping)
    end)

    it('should configure formatting', function()
      completion.setup()
      assert.is_not_nil(_G._test_cmp_config.formatting)
      assert.is_function(_G._test_cmp_config.formatting.format)
    end)
  end)

  describe('Command-line completion', function()
    it('should setup cmdline completion', function()
      completion.setup()
      assert.is_true(#_G._test_cmdline_setup > 0)
    end)

    it('should setup / search completion', function()
      completion.setup()
      local has_search = false
      for _, cmd in ipairs(_G._test_cmdline_setup) do
        -- Mode can be a string or table of strings
        local mode = cmd.mode
        if type(mode) == 'table' then
          for _, m in ipairs(mode) do
            if m == '/' then
              has_search = true
              break
            end
          end
        elseif mode == '/' then
          has_search = true
          break
        end
      end
      assert.is_true(has_search)
    end)

    it('should setup : command completion', function()
      completion.setup()
      local has_command = false
      for _, cmd in ipairs(_G._test_cmdline_setup) do
        if cmd.mode == ':' then
          has_command = true
          break
        end
      end
      assert.is_true(has_command)
    end)
  end)

  describe('Graceful degradation', function()
    it('should return false when nvim-cmp is not available', function()
      package.loaded['modules.completion.completion'] = nil
      package.loaded['cmp'] = nil
      package.preload['cmp'] = nil

      local completion_module = require('modules.completion.completion')
      local result = completion_module.setup()

      assert.is_false(result)
    end)
  end)
end)
