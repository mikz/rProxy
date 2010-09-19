class RProxy::Server
  get '/login/?' do
    haml :login
  end
  
  post '/login/?' do
    authenticate_user!
    redirect "/p"
  end

  post '/unauthenticated/?' do
    @notice = "That username and password are not correct!"
    status 401
    haml :login
  end
  
  get '/logout/?' do
    logout_user!
    redirect '/login'
  end
  
  
  get "/test" do
    must_be_authorized! "/login"
    current_user.inspect
  end
  
  get "/user_data" do
    must_be_authorized! "/login"
    @user_data = current_user.user_data
    haml :user_data
  end
  
  get "/user/:controller/?" do
    controller = params[:controller].downcase.to_sym
    pass unless [:configs, :data].include?(controller)
    must_be_authorized! "/login"
    instance_variable_set "@#{controller}".to_sym, current_user.send(controller)
    haml controller
  end
  get "/user/:controller/:id/edit/?" do
    controller = params[:controller].downcase.to_sym
    pass unless [:config, :data].include?(controller)
    must_be_authorized! "/login"
    
    @plugins = Plugin.all
    instance_variable_set(
      "@#{controller}".to_sym,
      "User::#{controller.to_s.capitalize}".constantize.get(*params[:id].split(",")))
    haml "#{controller}/edit".to_sym
  end
  
  post "/user/:controller/:id/update/?" do
    controller = params[:controller].downcase.to_sym
    pass unless [:config, :data].include?(controller)
    must_be_authorized! "/login"
    
    @plugins = Plugin.all
    var = "User::#{controller.to_s.capitalize}".constantize.get *params[:id].split(",")
    instance_variable_set "@#{controller}".to_sym, var
    if var.update(params[controller])
      flash[:notice] = "Successfully saved"
      redirect "/user/#{controller.to_s.pluralize}"
    else
      haml "#{controller}/edit".to_sym
    end
  end
  
  get "/user/:controller/:id/destroy/?" do
    controller = params[:controller].downcase.to_sym
    pass unless [:config, :data].include?(controller)
    must_be_authorized! "/login"
    
    @plugins = Plugin.all
    var = "User::#{controller.to_s.capitalize}".constantize.get *params[:id].split(",")
    var.destroy
    redirect "/user/#{controller.to_s.pluralize}"
  end
  
  get "/user/:controller/new/?" do
    controller = params[:controller].downcase.to_sym
    pass unless [:config, :data].include?(controller)
    must_be_authorized! "/login"
    
    @plugins = Plugin.all
    instance_variable_set "@#{controller}".to_sym, "User::#{controller.to_s.capitalize}".constantize.new
    haml "#{controller}/new".to_sym
  end
  
  post "/user/:controller/create/?" do
    controller = params[:controller].downcase.to_sym
    pass unless [:config, :data].include?(controller)
    must_be_authorized! "/login"
    
    @plugins = Plugin.all
    var = "User::#{controller.to_s.capitalize}".constantize.new params[controller]
    var.user = current_user
    params[controller]['value'].force_encoding('UTF-8')
    DEBUG {%w{params[controller]['value'].encoding params[controller]['value']}}
    instance_variable_set "@#{controller}".to_sym, var
    if var.save
      flash[:notice] = "Successfully saved"
      redirect "/user/#{controller.to_s.pluralize}"
    else
      
        DEBUG {%w{var.errors}}
      haml "#{controller}/new".to_sym
    end
  end
end