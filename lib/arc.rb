class Arc
  attr_reader :a1, :a2
  def initialize(a1, a2)
    @a1 = a1
    @a2 = a2
  end

  def ==(other)
    ((self.a1 == other.a1 and self.a2 == other.a2) or (self.a1 == other.a2 and self.a2 == other.a1))
  end

  def key
    return "#{a1},#{a2}" if a1<a2
    return "#{a2},#{a1}"
  end
end
