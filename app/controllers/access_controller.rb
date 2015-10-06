class AccessController < ApplicationController

before_action :confirm_logged_in, :except => [:login, :attempt_login, :logout]

  def index
  end

  def login
  end

  def attempt_login
  	if params[:user_name].present? && params[:password].present?
  		found_user = User.where(:user_name => params[:user_name]).first
  		if found_user
  			authorized_user = found_user.authenticate(params[:password])
  		end
  	end
  	if authorized_user
      session[:user_id] = authorized_user.id
      session[:user_name] = authorized_user.user_name
  		flash[:notice] = "Your are now logged in."
  		redirect_to(:action=> 'index')
  	else
  		flash[:notice] = "Invalid username/password combination."
  		redirect_to(:action => 'login')
  	end
  end

  def logout
      session[:user_id] = nil
      session[:user_name] = nil
  	flash[:notice] = "Logged Out"
  	redirect_to(:action => 'login')
  end

  private 
  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(:action => 'login')
      return false
    else
      return true
    end
  end

end
