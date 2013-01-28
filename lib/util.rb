class Util
  def self.simple_time(time)
    { hour: time.hour, min: time.min, value: time.to_i } if time
  end
end
