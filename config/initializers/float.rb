class Float
  def to_money
    (self * 100).round/100.0
  end
end