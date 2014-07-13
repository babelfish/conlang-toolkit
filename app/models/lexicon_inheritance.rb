class LexiconInheritance < ActiveRecord::Base
  attr_accessible :parent_lexicon_id, :inherited_lexicon_id
  belongs_to :parent_lexicon,    :class_name => "Lexicon"
  belongs_to :inherited_lexicon, :class_name => "Lexicon"
end