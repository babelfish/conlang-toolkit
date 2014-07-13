class LexemesController < ApplicationController
  before_filter :find_lexeme_and_lexicon, :only => [:show, :edit, :update, :destroy]
  
  def create
    @lexeme = Lexeme.new params[:lexeme]
    
    if signed_in? and @lexeme.lexicon.user == current_user
      
      if @lexeme.save
        if params[:tags]
          params[:tags].each do |t|
            t = LexemeTag.new :name => t
            t.lexeme = @lexeme
            
            unless t.save
              flash[:error] = "There was an error saving tag: #{t}"
            end
          end
        end
        
        # Extract definition and usage note lists and their indices from params for easy iteration.
        @definitions = params.each_key.select { |k| k =~ /definition/ }.map { |k| [k.match(/(\d+)/)[1].to_i - 1, params[k]] }
        @notes       = params.each_key.select { |k| k =~ /notes/      }.map { |k| [k.match(/(\d+)/)[1].to_i - 1, params[k]] }
        
        unless @definitions.empty?
          @definitions.each do |d|
            new_definition = Definition.new :text => d[1]
            new_definition.lexeme = @lexeme
            
            if new_definition.save
              if @notes.index { |i| i[0] == d[0] } # If there's a usage note with the same index as the definition
                new_note = UsageNote.new :text => @notes[d[0]][1]
                new_note.definition = new_definition
                
                if new_note.nil? or !new_note.save
                  flash[:error] = "There was an error saving usage note with text: #{@notes[d[0]][1]}"
                end
              end
            else
              flash[:error] = "There was an error saving definition with text: #{d[1]}"
            end
          end
        end
        
        flash[:success] = "lexeme #{@lexeme.name} successfully created."
        redirect_to @lexeme.lexicon
      else
        render 'new'
      end
    else
      flash[:error] = "Tried to add lexeme to unowned lexicon." if @lexeme.lexicon.user != current_user
      redirect_back_or root_path
    end
  end
  
  def new
    if signed_in?
      @lexeme           = Lexeme.new
      @lexicons_options = current_user.lexicons.map { |l| [ l.name, l.id ] }
      @tags_options     = LexemeTag.pluck(:name).uniq
    else
      redirect_back_or root_path
    end
  end
  
  def show
    @lexeme  = Lexeme.find(params[:id])
    @lexicon = @lexeme.lexicon
    
    if @lexicon.public or current_user == @lexicon.user
      @definitions = @lexeme.definitions
    else
      redirect_back_or root_path
    end
  end
  
  def destroy
    @lexeme = Lexeme.find params[:id]
    
    if @lexeme.lexicon.user == current_user
      lexicon = @lexeme.lexicon
      @lexeme.destroy
      
      redirect_to lexicon
    end
  end
  
  def edit
    @lexeme = Lexeme.find(params[:id])
    @lexicon = @lexeme.lexicon
    
    if current_user == @lexicon.user
      @lexicons_options = current_user.lexicons.map { |l| [ l.name, l.id ] }
      @tags_options     = @lexeme.lexeme_tags.map { |t| t.name }
      @definitions      = @lexeme.definitions
    else
      redirect_back_or root_path
    end
  end
  
  def update
    @lexeme = Lexeme.find(params[:id])
    @lexicon = @lexeme.lexicon
    
    if current_user == @lexicon.user
      if @lexeme.update_attributes(params[:lexeme])
        existing_definitions = true
        if params[:existing_definition]
          params[:existing_definition].each do |k, v|
            d = Definition.find(k)
            d.text = v
            
            if d.nil? or !d.save
              flash[:error] = "There was an error saving definition with text: #{v}"
              existing_definitions = false
            end
          end
        end
        
        existing_notes = true
        if params[:existing_notes]
          params[:existing_notes].each do |k, v|
            un = UsageNote.find(k)
            un.text = v
            
            if un.nil? or !un.save
              flash[:error] = "There was an error saving usage note with text: #{v}"
              existing_notes = false
            end
          end
        end
        
        new_definitions = true
        if params[:definition]
          params[:definition].each do |k, v|
            d = Definition.new( text: v, lexeme_id: @lexeme.id )
            if d.save
              if params[:notes]
                un = UsageNote.new( text: params[:notes][k], definition_id: d.id ) if params[:notes][k]
                
                if un.nil? or !un.save
                  flash[:error] = "There was an error saving usage note with text: #{params[:notes][k]}"
                end
              end
            else
              flash[:error] = "There was an error saving definition with text: #{v}"
            end
          end
        end
        
        if existing_definitions and existing_notes and new_definitions
          redirect_to @lexeme and return
        end
      end
      
      @definitions = @lexeme.definitions
      render 'edit'
    else
      redirect_back_or root_path
    end
  end
  
  protected
    def find_lexeme_and_lexicon
      @lexeme = Lexeme.find(params[:id])
      @lexicon = @lexeme.lexicon
    end
end
