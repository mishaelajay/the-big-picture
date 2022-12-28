load './app/errors/invalid_path_error.rb'

desc "Download images from urls in txt file"
task :download_images, [:source_file_path, :images_target_path] => :environment do |t, args|
  source_file_path = args.source_file_path
  images_target_path = args.images_target_path
  all_invalid_urls = []

  check_path_validity(source_file_path, 'file')
  check_path_validity(images_target_path, 'dir')

  parser_service = ImageUrlsFileParser.new(filepath: source_file_path)
  urls = parser_service.next

  url_cache_service.flush_redis_cache

  until urls.empty? do
    valid_unique_urls, invalid_urls = filter_invalid_duplicate_urls(urls.map(&:strip))
    url_cache_service.set_download_attempted(valid_unique_urls)
    all_invalid_urls << invalid_urls
    ImageDownloadWorkerJob.perform_async(valid_unique_urls, images_target_path)
    urls = parser_service.next
  end

  all_invalid_urls = all_invalid_urls.flatten.reject(&:blank?)
  puts "These invalid urls were not downloaded #{all_invalid_urls}"
end


def filter_invalid_duplicate_urls(urls)
  urls.uniq!
  valid_urls = filter_out_invalid_urls(urls)
  invalid_urls = urls - valid_urls
  unique_valid_urls = url_cache_service.remove_attempted_urls(valid_urls)
  [unique_valid_urls, invalid_urls]
end

def filter_out_invalid_urls(urls)
  urls.select { |url| url_validator_service(url).validate_url }
end

def url_validator_service(url)
  UrlValidator.new(url)
end

def check_path_validity(path, type)
  fpv = PathValidator.new(path: path, type: type)
  raise InvalidPathError.new unless fpv.valid_path?
  rescue InvalidPathError => e
    puts "#{e.message}, path: #{path}"
end

def url_cache_service
  UrlCacher.new(REDIS_CACHE)
end