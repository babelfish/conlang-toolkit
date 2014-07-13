class LexiconsController < ApplicationController
  def create
    if user_signed_in?
      @lexicon = Lexicon.new params[:lexicon]
      
      if @lexicon.save
        flash[:success] = "Lexicon #{@lexicon.name} successfully created."
        redirect_to @lexicon
      else
        render 'new'
      end
    else
      redirect_back_or root_path
    end
  end
  
  def new
    if user_signed_in?
      @lexicon = Lexicon.new( :user_id => current_user.id )
    else
      redirect_back_or root_path
    end
  end
  
  def show
    @lexicon = Lexicon.find(params[:id])
    
    if @lexicon and (@lexicon.public or (current_user == @lexicon.user))
      @lexemes = @lexicon.lexemes.order('name ASC')
    else
      flash[:error] = "You attempted to access a private lexicon or you are not signed in."
      redirect_back_or root_path
    end
  end
  
  def destroy
    @lexicon = Lexicon.find(params[:id])
    
    if current_user == @lexicon.user
      @lexicon.lexemes.each do |l|
        l.definitions.each do |d|
          d.usage_note.destroy if !d.usage_note.nil?
          d.destroy if !d.nil?
        end
        l.destroy if !l.nil?
      end
      
      if !@lexicon.destroy
        flash.now[:error] = "Unable to delete lexicon. Please try again. If the problem persists, contact the site administrator."
        render 'edit'
      else
        flash[:success] = "Lexicon deleted."
        redirect_to root_path
      end
    else
      flash[:error] = "Access denied."
      redirect_back_or root_path
    end
  end
  
  def edit
    @lexicon = Lexicon.find(params[:id])
    
    if current_user != @lexicon.user
      flash[:error] = "You do not have access to that lexicon."
      redirect_back_or root_path
    end
    
    @lexicons = current_user.lexicons.reject { |l| l == @lexicon }
    @conlangs = current_user.conlangs
  end
  
  def update
    @lexicon = Lexicon.find(params[:id])
    
    if current_user == @lexicon.user
      @lexicon.inherited_lexicons.clear
      
      ((params[:inherited_lexicons].split ",").map { |l| Lexicon.find l }).each { |l| @lexicon.inherited_lexicons << l if current_user? l.user }
      
      if @lexicon.update_attributes(params[:lexicon])
        redirect_to @lexicon
      else
        flash.now[:error] = "An error occurred attempting to save changes."
        render 'edit'
      end
    else
      flash[:error] = "You do not have access to that lexicon."
      redirect_back_or root_path
    end
  end
  
  def index
    @lexicons = Lexicon.order('user_id').where :public => true
    
    render :layout => "metro", :inline => "<p>No public lexicons currently exist.</p>" if @lexicons.nil?
  end
end
