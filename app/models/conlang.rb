class Conlang < ActiveRecord::Base
    belongs_to :user
    has_one  :timeline
    has_many :lexicons
    
    @alignment_opts = %w{ Accusative Ergative Split\ Ergative Austronesian Active-stative Tripartite Marked\ Nominative }
    @type_opts      = %w{ Isolating Agglutinating Fusional Mixed }
    @order_opts     = %w{ SOV SVO VSO VOS OSV OVS }
    
    validates :name,        :presence  => true, :length => { :within => 2..40 }
    validates :user_id,     :presence  => true
    validates :alignment,   :inclusion => @alignment_opts
    validates :morpho_type, :inclusion => @type_opts
    validates :word_order,  :inclusion => @order_opts
    
    def self.alignment_opts
        @alignment_opts
    end
    
    def self.type_opts
        @type_opts
    end
    
    def self.order_opts
        @order_opts
    end
end
