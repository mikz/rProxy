class VariablesController < ApplicationController
  inherit_resources
  defaults :resource_class => Plugin::Variable
  
protected
  def begin_of_association_chain
    current_user
  end
  
  def collection
    @variables ||= end_of_association_chain
  end
  
  def build_resource
    @variable ||= end_of_association_chain.send method_for_build, {:plugin_id => params[:plugin_id] }.merge(params[resource_request_name] || {})
  end
end
