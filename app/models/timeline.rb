class Timeline < ActiveRecord::Base
  belongs_to :lexicon
  belongs_to :conlang
end
