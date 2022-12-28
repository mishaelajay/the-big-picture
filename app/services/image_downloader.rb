# frozen_string_literal: true

require 'open-uri'

# Download image onto local storage from a given url
class ImageDownloader
  attr_accessor :path, :url, :max_size_in_mb, :image_extension
  def initialize(url:, path:, max_size_in_mb: 30.0)
    @url = url
    @path = path
    @max_size_in_mb = max_size_in_mb
    @image_extension = nil
  end

  def download_and_save
    downloaded_file = download_image

    raise NotAnImageError.new unless is_image?(downloaded_file)
    raise ImageTooBigError.new if image_too_big?(downloaded_file)
    raise OutOfDiskSpaceError.new unless disk_space_available?(downloaded_file)

    save_to_path(downloaded_file)
    true
  end

  private

  def download_image
    parsed_url.open(read_timeout: 10)
  end

  def save_to_path(downloaded_file)
    File.open(full_path, 'wb+') { |f| f.write(downloaded_file.read) }
  end

  def full_path
    path + "/#{file_name}"
  end

  def file_name
    "#{random_string}--#{File.basename(parsed_url.path)}.#{image_extension}"
  end

  def parsed_url
    URI.parse(@url.strip)
  end

  def image_too_big?(downloaded_file)
    file_size_in_mb(downloaded_file) > max_size_in_mb
  end

  def disk_space_available?(downloaded_file)
    current_available_disk_space > file_size_in_mb(downloaded_file)
  end

  def file_size_in_mb(downloaded_file)
    downloaded_file.size.to_f/2**20
  end

  def current_available_disk_space
    stat = Sys::Filesystem.stat("/")
    (stat.block_size * stat.blocks_available).to_f / 2**20
  end

  def random_string
    SecureRandom.alphanumeric(5)
  end

  def is_image?(downloaded_file)
    content_type = downloaded_file.content_type
    self.image_extension = content_type.split('/').last
    content_type.include?('image')
  end
end
