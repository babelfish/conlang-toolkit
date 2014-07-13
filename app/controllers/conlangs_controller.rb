class ConlangsController < ApplicationController
  def create
    if signed_in?
      @conlang   = Conlang.new   params[:conlang]
      
      if @conlang.save
        redirect_to @conlang
      else
        render 'new'
      end
    else
      redirect_back_or root_path
    end
  end
  
  def new
    if signed_in?
      @conlang = Conlang.new( :user_id => current_user.id )
    else
      redirect_back_or root_path
    end
  end
  
  def update
    @conlang   = Conlang.find params[:id]
    
    if current_user? @conlang.user
      if @conlang.update_attributes(params[:conlang])
        redirect_to @conlang
      else
        flash.now[:error] = "An error occurred attempting to save changes."
        render 'edit'
      end
    else
      flash[:error] = "You do not have access to that conlang."
      redirect_back_or root_path
    end
  end
  
  def edit
    @conlang = Conlang.find params[:id]
    
    redirect_back_or root_path unless current_user? @conlang.user
  end
  
  def show
    @conlang = Conlang.find params[:id]
    
    redirect_back_or root_path unless @conlang.public or current_user? @conlang.user
  end
  
  def index
    @conlangs = Conlang.where :public => true
    
    render :layout => "metro", :inline => "<p>No public conlangs currently exist.</p>" if @conlangs.nil?
  end
  
  def destroy
    @conlang = Conlang.find params[:id]
    
    if current_user? @conlang.user
      if !@conlang.destroy
        flash.now[:error] = "Unable to delete lexicon. Please try again. If the problem persists, contact the site administrator."
        render 'edit'
      else
        flash[:success] = "Conlang successfully deleted."
        
        redirect_to root_path
      end
    else
      flash[:error] = "Access denied."
      redirect_back_or root_path
    end
  end
end
