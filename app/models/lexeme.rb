class Lexeme < ActiveRecord::Base
  belongs_to :lexicon
  has_many :definitions, :dependent => :destroy
  has_many :lexeme_tags, :dependent => :delete_all
  has_many :usage_notes, :through => :definitions
  
  attr_accessible :name, :part, :transcription, :lexicon_id
  
  scope :recent, order("#{table_name}.created_at DESC").limit(3).joins(:lexicon).where('lexicons.public' => true)
  
  validates :name,          :presence => true
  validates :part,          :presence => true
  validates :transcription, :presence => true
  validates :lexicon_id,    :presence => true
  
  def self.generate options = {}
    options.reverse_merge! :num_words => 1
    variables = {}
    
    if !options[:variables].nil?
      begin
        variables = split_variables options[:variables]
      rescue
        return "error[Error parsing syllable structure data.]"
      end
    else
      return "error[No syllable structure data or lexicon specified.]" if options[:lexicon].nil?
      
      conlang = (Lexicon.find options[:lexicon]).conlang
      return "error[This lexicon is not associated with a conlang and no syllable structure data provided.]" if conlang.nil?
      
      syllabe_structure = conlang.phonology.syllable_structure
      return "error[No syllable structure data provided or present in the conlang associated with this lexicon.]" if syllabe_structure.nil?
      
      begin
        variables = split_variables syllabe_structure
      rescue
        return "error[Error parsing syllable structure data.]"
      end
    end
    
    return "error[Medial syllable structure missing.]" if variables["medial"].nil? or variables["medial"].empty?
    
    begin
      initial             = ""
      final               = ""
      medial              = parse_structures variables["medial"]
      variables["medial"] = nil
      
      if !variables["initial"].nil?
        initial = parse_structures variables["initial"]
        variables["initial"] = nil
      else
        initial = medial
      end
      
      if !variables["final"].nil?
        final = parse_structures variables["final"]
        variables["final"] = nil
      else
        final = medial
      end
    rescue
      return "error[Error parsing syllable structure data.]"
    end
    
    # Parse each variable into an array of strings.
    variables.each { |k, v| variables[k] = parse_variables v }
    # Then iterate over each array and expand references to other variables.
    variables.each { |k, v| v.map! { |x| ( variables[x[1..-2]] if v =~ /\[.+\]/ ) or x } }
    # Then merge the expansions into their parent arrays and remove duplicate values.
    variables.each { |k, v| v.flatten!.uniq! }
    
    [].fill(0, options[:num_words]) { make_word :num_syllables => variables["num_syllables"],
                                                :initial       => initial,
                                                :medial        => medial,
                                                :final         => final }
  end
  
  protected
    def split_variables input
      v = {}
      input.lines.each do |line|
        parts = line.split "="
        parts.each { |p| p.strip! }
        
        v[parts[0]] = parts[1] if !parts[0].empty? and !parts[1].nil?
      end
      v
    end
    
    def parse_variables v
      output = []
      i = 0
      
      for i in 0..v.len
        if v[i] == "<"
          j = i + 1
          
          j += 1 until v[j] == ">"
          
          arr = (v[i+1..j-1].split "/")
          
          output << arr[rng.rand arr.len]
          
          i = j + 1
        elsif v[i] == "["
          j = i + 1
          
          j += 1 until v[j] == "]"
          
          arr = (v[i+1..j-1].split "/")
          
          output << "[#{arr[rng.rand arr.len]}]"
          
          i = j + 1
        else
          output << v[i]
          i += 1
        end
      end
      
      output
    end
    
    def parse_structures s
      str = ""
      output = []
      optional = 0
      literal = 0
      variable = 0
      
      input.each_char do |c|
        if c == "<"
          literal += 1
        elsif c == ">"
          literal -= 1
        else
        
        end
      end
      
      output
    end
    
    def make_word options = {}
      options.reverse_merge! :num_syllables => 3
      word = ""
      
      for i in 1..(Random.new.rand 1..options[:num_syllables])
        if i == 1
          word << (make_syllable options[:initial])
        elsif i == options[:num_syllables]
          word << (make_syllable options[:final])
        else
          word << (make_syllable options[:medial])
        end
      end
      
      word
    end
    
    def make_syllable
      rng = Random.new
      opt = [true, false]
      
      
    end
end
