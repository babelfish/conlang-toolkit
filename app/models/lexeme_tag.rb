class LexemeTag < ActiveRecord::Base
  belongs_to :lexeme
  attr_accessible :name
  
  validates :name, :presence => true
  validates :lexeme_id, :presence => true
end
