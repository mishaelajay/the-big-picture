class ImageDownloadWorkerJob
  include Sidekiq::Job
  sidekiq_options queue: 'image_downloads', retry: 0

  def perform(urls, path)
    urls.each do |url|
      download_image(url, path)
    end
  end

  private

  def download_image(url, path)
    begin
      ImageDownloader.new(
        url: url,
        path: path
      ).download_and_save
    rescue OutOfDiskSpaceError, ImageTooBigError, NotAnImageError => e
      log_failure(url, message: e.message)
    rescue
      log_failure(url)
    end
  end

  def log_failure(url, message: nil)
    Rails.logger.info "The following url download has failed #{url}, reason below"
    Rails.logger.info message
  end
end
