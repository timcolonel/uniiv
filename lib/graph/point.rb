class Point
  @x = 0
  @y = 0

  attr_accessor :x, :y

  def initialize(x = 0, y = 0)
    @x = x.to_f
    @y = y.to_f
  end

  def self.pos_from_array(array)
    x = 0
    y = 0

    if array.size >= 2 #Format [x,y]
      x = array[0]
      y = array[1]
      Point.new(x, y)
    end
  end

  def self.dim_from_array(array)
    x = 0
    y = 0
    if array.size == 2 #Format [x,y]
      x = array[0]
      y = array[1]
    elsif array.size == 4 #Format [0,0,x,y]
      x = array[2] - array[0]
      y = array[3] - array[1]
    end
    Point.new(x, y)
  end


  def - (point)
    @x -= point.x
    @y -= point.y
    self
  end

  def to_s
    '(' + @x.to_s + ', ' + @y.to_s + ')'
  end
end