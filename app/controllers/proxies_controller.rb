class ProxiesController < ApplicationController
#  before_filter :authenticate_user!
  
  def index
    @plugins = Plugin::Base.all
  end

end
