# The templates export controller for serving up sereth template manager templates
class Sereth::Templates < ApplicationController
  # Run user-configured access controls to check the template is accessible from this context
  before_filter do
    @templates = params['templates']
    @templates = [templates] if !templates.is_a?(Array)
    return if !TemplateManager.access?
    return TemplateManager.check_access(@templates, params['action'])
  end

  # Render the requested templates
  def show
    render :text => TemplateManager.get(@templates), :content_type => 'application/javascript'
  end
end