require 'rails_helper'

RSpec.describe UrlValidator do
  context 'invalid url' do
    let(:invalid_url) { 'ww.google.foo'}

    it 'should return false' do
      iuv = UrlValidator.new(invalid_url)
      expect(iuv.validate_url).to be false
    end
  end


  context 'valid image url' do
    let(:valid_image_url) { 'https://www.google.com/nice_image.jpg' }
    it 'should return true' do
      iuv = UrlValidator.new(valid_image_url)
      expect(iuv.validate_url).to be true
    end
  end
end