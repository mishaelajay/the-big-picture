# Using a different db for handling duplicate urlss
REDIS_CACHE = Redis.new(
  url: 'redis://localhost:6379/1'
)