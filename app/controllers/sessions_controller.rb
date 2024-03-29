class SessionsController < ApplicationController
  def create
    user ||= User.find_by_email(params[:session][:login].downcase)
    
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or "/users/#{user.name}"
    else
      flash[:error] = 'Invalid email/password combination' # Not quite right!
      redirect_back_or ""
    end
  end
  
  def destroy
    sign_out
    redirect_to ""
  end
end
