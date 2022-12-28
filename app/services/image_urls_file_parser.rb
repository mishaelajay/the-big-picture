# frozen_string_literal: true

# Image URLs file reader

class ImageUrlsFileParser
  attr_reader :file, :filepath, :batch_size

  def initialize(filepath:, batch_size: 25)
    @filepath = filepath
    @batch_size = batch_size
    @file = File.open(filepath)
  end

  def rewind
    file.rewind
  end

  def next
    urls = []
    batch_size.times do
      return urls if file.eof?
      urls << file.readline(' ', chomp: true)
    end
    urls
  end
end