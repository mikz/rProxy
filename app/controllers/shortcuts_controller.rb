class ShortcutsController < ApplicationController
  inherit_resources
  
  def show
    
    redirect_to("/p?" << resource.query)
  end
protected
  def begin_of_association_chain
    current_user
  end

  def collection
    @shortcuts ||= end_of_association_chain
  end

  def build_resource
    @shortcut ||= end_of_association_chain.send method_for_build, {:plugin_id => params[:plugin_id] }.merge(params[resource_request_name] || {})
  end
end
