--[[
Rails Projections
=================

Augment vim-rails default projections with modern Rails patterns:
- ViewComponents
- Service objects
- Concerns
- Serializers
- Policies
- Jobs
- Query objects
- Form objects
--]]

return {
  -- ViewComponents (modern Rails view layer)
  ['app/components/*_component.rb'] = {
    command = 'component',
    test = 'spec/components/%s_component_spec.rb',
    template = {
      '# frozen_string_literal: true',
      '',
      'class {camelcase|capitalize|colons}Component < ViewComponent::Base',
      '  def initialize',
      '  end',
      'end',
    },
  },

  ['app/components/*_component.html.erb'] = {
    alternate = 'app/components/%s_component.rb',
  },

  -- Service objects
  ['app/services/*.rb'] = {
    command = 'service',
    test = 'spec/services/%s_spec.rb',
    template = {
      '# frozen_string_literal: true',
      '',
      'class {camelcase|capitalize|colons}',
      '  def call',
      '    # TODO',
      '  end',
      'end',
    },
  },

  -- Model concerns
  ['app/models/concerns/*.rb'] = {
    command = 'concern',
    test = 'spec/models/concerns/%s_spec.rb',
    template = {
      '# frozen_string_literal: true',
      '',
      'module {camelcase|capitalize|colons}',
      '  extend ActiveSupport::Concern',
      'end',
    },
  },

  -- Controller concerns
  ['app/controllers/concerns/*.rb'] = {
    command = 'controllerconcern',
    test = 'spec/controllers/concerns/%s_spec.rb',
  },

  -- Serializers
  ['app/serializers/*_serializer.rb'] = {
    command = 'serializer',
    test = 'spec/serializers/%s_serializer_spec.rb',
    related = 'app/models/%s.rb',
  },

  -- Jobs
  ['app/jobs/*_job.rb'] = {
    command = 'job',
    test = 'spec/jobs/%s_job_spec.rb',
  },

  -- Policies (Pundit)
  ['app/policies/*_policy.rb'] = {
    command = 'policy',
    test = 'spec/policies/%s_policy_spec.rb',
    related = 'app/models/%s.rb',
  },

  -- Query objects
  ['app/queries/*_query.rb'] = {
    command = 'query',
    test = 'spec/queries/%s_query_spec.rb',
  },

  -- Form objects
  ['app/forms/*_form.rb'] = {
    command = 'form',
    test = 'spec/forms/%s_form_spec.rb',
  },

  -- Presenters/Decorators
  ['app/presenters/*_presenter.rb'] = {
    command = 'presenter',
    test = 'spec/presenters/%s_presenter_spec.rb',
    related = 'app/models/%s.rb',
  },

  -- Subsystems/Engines
  ['engines/*/app/models/*.rb'] = {
    command = 'enginemodel',
    test = 'engines/{}/spec/models/%s_spec.rb',
  },

  ['engines/*/app/controllers/*_controller.rb'] = {
    command = 'enginecontroller',
    test = 'engines/{}/spec/controllers/%s_controller_spec.rb',
  },
}
