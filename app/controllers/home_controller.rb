class HomeController < ApplicationController
  def index
    @lexicons = current_user.lexicons if signed_in?
    @conlangs = current_user.conlangs if signed_in?
  end

  def markdown_help
  
  end
end
