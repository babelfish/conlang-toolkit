class Lexicon < ActiveRecord::Base
  belongs_to :user
  belongs_to :conlang
  has_one    :timeline
  has_many   :lexemes
  has_many   :definitions,             :through => :lexemes,                  :dependent  => :destroy
  has_many   :usage_notes,             :through => :definitions,              :dependent  => :destroy
  has_many   :sound_changes,           :through => :timeline,                 :dependent  => :destroy
  has_many   :parent_lexicon_links,    :foreign_key => :inherited_lexicon_id, :dependent  => :destroy, :class_name => "LexiconInheritance"
  has_many   :inherited_lexicon_links, :foreign_key => :parent_lexicon_id,    :dependent  => :destroy, :class_name => "LexiconInheritance"
  has_many   :parent_lexicons,         :through => :parent_lexicon_links,     :class_name => "Lexicon" 
  has_many   :inherited_lexicons,      :through => :inherited_lexicon_links,  :class_name => "Lexicon"
  
  attr_accessible :name, :public, :user_id, :conlang_id
  
  validates :name,    :presence => true, :length => { :within => 4..40 }
  validates :user_id, :presence => true
end
