module Utils
  class Ratio
    attr_accessor :ratio, :coefficient

    def initialize(ratio, coefficient=1)
      self.ratio = ratio
      self.coefficient = coefficient
    end

    def ratio=(r)
      if r > 1
        r = 1
      end
      @ratio = r.to_f
    end

    def coefficient=(c)
      @coefficient = c.to_f
    end

    def value
      @ratio * @coefficient
    end

    def percent
      @ratio * 100
    end

    def +(other)
      output = Utils::Ratio.zero
      if other.is_a? Utils::Ratio
        output.ratio = (value+other.value)/(@coefficient+other.coefficient) unless @coefficient == 0 and other.coefficient == 0
        output.coefficient = @coefficient + other.coefficient
      end
      output
    end

    def <(other)
      @ratio < other.ratio
    end

    def >(other)
      @ratio > other.ratio
    end

    def ==(other)
      @ratio == other.ratio
    end

    def <=>(other)
      if self < other
        -1
      elsif self == other
        0
      else
        1
      end
    end

    def full?
      @ratio == 1
    end

    def empty?
      @ratio == 0
    end

    def self.full(coefficient = 1)
      Utils::Ratio.new(1, coefficient)
    end

    def self.empty
      Utils::Ratio.new(0)
    end

    #Create a ratio with ratio =0 and coef = 0
    def self.zero
      Utils::Ratio.new(0, 0)
    end

    def self.from_value(value, coefficient)
      Utils::Ratio.new(value.to_f/coefficient.to_f, coefficient.to_f)
    end

    def to_s
      @ratio.to_s
    end

    alias_attribute :to_percent, :percent
  end
end