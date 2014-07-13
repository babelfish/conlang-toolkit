class Definition < ActiveRecord::Base
  belongs_to :lexeme
  has_one :usage_note, :dependent => :destroy
  attr_accessible :text
  
  validates :text,      :presence => true
  validates :lexeme_id, :presence => true
end
