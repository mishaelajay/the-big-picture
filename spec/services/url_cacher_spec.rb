require 'rails_helper'

RSpec.describe UrlCacher do
  context 'should set and get urls from cache' do
    let(:urls) { %w[www.google.com www.facebook.com www.yelp.com] }
    let(:cache_service) {
      UrlCacher.new(MockRedis.new)
    }
    it 'should get and set urls in cache' do
      cache_service.set_download_attempted(urls)
      expect(cache_service.redis_cache.keys).to match_array(urls)
      cache_service.flush_redis_cache
      expect(cache_service.redis_cache.keys).to be_empty
    end
  end
end
