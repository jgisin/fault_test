class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  @init_fault = 0

  private 
  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'access', :action => 'login')
      return false
    else
      return true
    end
  end

    def get_user
      if params[:user_id]
        @user = User.find(params[:user_id])
      end
    end

        def get_project
      if params[:project_id]
        @project = Project.find(params[:project_id])
      end
    end
    
    
end
