$redis = Redis.new( :host => 'localhost', :port => 6379 )

# Build the trie for the course autocomplete
# use subjects for starters
Subject.all.each do |subject|
  $redis.sadd("subjects", subject.id)
  str = subject.code
  size = str.size

  current_str = ""
  size.times do |i|
    current_str += str[i]
    $redis.sadd("subjects:#{current_str}", subject.id)
  end
end
