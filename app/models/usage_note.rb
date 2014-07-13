class UsageNote < ActiveRecord::Base
  belongs_to :definition
  attr_accessible :text
  
  validates :text,          :presence => true
  validates :definition_id, :presence => true
end
