--[[
Angular Projections
===================

Custom projectionist configurations for Angular projects.
--]]

return {
  -- Component
  ['src/app/*/*.component.ts'] = {
    type = 'component',
    alternate = {
      'src/app/{}.component.spec.ts',
      'src/app/{}.component.html',
      'src/app/{}.component.scss',
    },
  },

  -- Component Template
  ['src/app/*/*.component.html'] = {
    type = 'template',
    alternate = 'src/app/{}.component.ts',
  },

  -- Component Styles
  ['src/app/*/*.component.scss'] = {
    type = 'styles',
    alternate = 'src/app/{}.component.ts',
  },

  -- Component Spec
  ['src/app/*/*.component.spec.ts'] = {
    type = 'spec',
    alternate = 'src/app/{}.component.ts',
  },

  -- Service
  ['src/app/*/*.service.ts'] = {
    type = 'service',
    alternate = 'src/app/{}.service.spec.ts',
  },

  -- Module
  ['src/app/*/*.module.ts'] = {
    type = 'module',
  },
}
