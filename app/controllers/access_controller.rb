class AccessController < ApplicationController
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
  		flash[:notice] = "Your are now logged in as #{found_user.user_name}."
  		redirect_to(:action=> 'index')
  	else
  		flash[:notice] = "Invalid username/password combination."
  		redirect_to(:action => 'login')
  	end
  end

  def logout
  	flash[:notice] = "Logged Out"
  	redirect_to(:action => 'login')
  end

end
