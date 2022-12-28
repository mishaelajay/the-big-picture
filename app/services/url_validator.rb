# frozen_string_literal: true

# validates a image url
class UrlValidator
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def validate_url
    return false unless url.present?
    url?
  end

  private

  def url?
    uri = parsed_url
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  end

  def parsed_url
    URI.parse(url)
  end
end
