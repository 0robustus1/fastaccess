Fastaccess.setup do
  set_redis Redis.new(:host => 'localhost', :port => 6379)
end
