module Grammar

class T
  attr_accessor :word

  def initialize word
    @word = word
  end

  def to_s
    "T<#{@word}>"
  end
end

class NT
  attr_accessor :symbol, :index

  def initialize symbol=nil, index=nil
    @symbol = symbol
    @index  = index
  end

  def from_s s
    @symbol, @index = s.delete('[]').split ','
    @symbol.strip!
    @index = @index.to_i-1
  end

  def self.from_s s
    n = NT.new
    n.from_s s
    return n
  end

  def to_s
    "NT<#{@symbol},#{@index}>"
  end
end

class Rule
  attr_accessor :lhs, :rhs, :target, :map

  def initialize lhs=nil, rhs=nil, target=nil, map=nil
    @lhs    = lhs
    @rhs    = rhs
    @target = target
    @map    = (map ? map : [])
    @arity_ = nil
  end

  def to_s
    "#{@lhs.to_s} -> #{@rhs.map{ |i| i.to_s }.join ' '} ||| #{@target.map{ |i| i.to_s }.join ' '} [arity=#{arity}]"
  end

  def arity
    @arity_ = rhs.select { |i| i.class == NT }.size if !@arity_
    return @arity_
  end

  def read_right_ s, fill_map=false
    _ = []
    s.split.each { |x|
      x.strip!
      if x[0]=='[' && x[x.size-1] == ']'
        _ << NT.from_s(x)
        @map << _.last.index if fill_map
      else
        _ << T.new(x)
      end
    }
    return _
  end

  def from_s s
    lhs, rhs, target = splitpipe s, 3
    @lhs = NT.from_s lhs
    @rhs = read_right_ rhs
    @target = read_right_ target, true
  end

  def self.from_s_x s
    r = self.new
    r.from_s s
    return r
  end
end

class Grammar
  attr_accessor :rules, :startn, :startt, :flat

  def initialize fn
    @rules = []; @startn = []; @startt = []; @flat = []
    ReadFile.readlines_strip(fn).each_with_index { |s,i|
      STDERR.write '.'; STDERR.write " #{i+1}\n" if (i+1)%80==0
      @rules << Rule.from_s(s)
      if @rules.last.rhs.first.class == NT
        @startn << @rules.last
      else
        if rules.last.arity == 0
          @flat << @rules.last
        else
          @startt << @rules.last
        end
      end
    }
    STDERR.write "\n"
  end

  def to_s
    s = ''
    @rules.each { |r| s += r.to_s+"\n" }
    return s
  end

  def add_glue_rules
    @rules.map { |r| r.lhs.symbol }.select { |s| s != 'S' }.uniq.each { |symbol|
      @rules << Rule.new(NT.new('S'), [NT.new(symbol, 0)], [NT.new(symbol, 0)], [0])
      @startn << @rules.last
      @rules << Rule.new(NT.new('S'), [NT.new('S', 0), NT.new('X'), 1], [NT.new('S', 0), NT.new('X'), 1], [0, 1])
      @startn << @rules.last
    }
  end

  def add_pass_through_rules s
    s.each { |word|
      @rules << Rule.new(NT.new('X'), [T.new(word)], [T.new(word)])
      @flat << @rules.last
    }
  end
end


end # module

