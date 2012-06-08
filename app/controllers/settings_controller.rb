class SettingsController < ApplicationController
  inherit_resources
  defaults :resource_class => Plugin::Setting
  
protected
  def begin_of_association_chain
   current_user
  end
  def collection
    @settings ||= end_of_association_chain
  end
end
