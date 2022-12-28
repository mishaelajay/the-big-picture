class UrlCacher
  attr_reader :redis_cache
  def initialize(redis_cache)
    @redis_cache = redis_cache
  end

  def set_download_attempted(urls)
    return if urls.empty?
    url_hash = Hash[urls.map {|url| [url, 1]}].with_indifferent_access
    redis_cache.mapped_mset(url_hash)
  end

  def remove_attempted_urls(urls)
    cached_urls = fetch_cached_urls_if_present(urls)
    urls.select{ |url| cached_urls[url] != 1 }
  end

  def fetch_cached_urls_if_present(urls)
    redis_cache.mapped_mget(*urls)
  end

  def flush_redis_cache
    redis_cache.flushall
  end
end