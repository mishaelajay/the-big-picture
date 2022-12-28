require 'rails_helper'

RSpec.describe ImageDownloader do
  context 'Large image download' do
    let(:large_image_url) {
      'https://images.pexels.com/photos/1054666/pexels-photo-1054666.jpeg?cs=srgb&dl=pexels-harvey-sapir-1054666.jpg'
    }
    let(:max_size_in_mb) { 1 }

    it 'should raise ImageTooBigError when image is large' do
      downloader = ImageDownloader.new(
        url: large_image_url,
        path: '../fixtures/test_downloads',
        max_size_in_mb: max_size_in_mb
      )
      expect{ downloader.download_and_save }.to raise_error(ImageTooBigError
                                                ).with_message('This image is larger than the max size passed by you'
      )
    end
  end

  context 'Disk space is low' do
    let(:image_url){
      'https://www.exceptionalcreatures.com/assets/images/bestiary/Net/OpenTimeout.png'
    }

    it 'should raise OutOfDiskSpaceError' do
      downloader = ImageDownloader.new(
        url: image_url,
        path: '../fixtures/test_downloads'
      )
      allow(downloader).to receive(:disk_space_available?).and_return(false)
      expect{ downloader.download_and_save }.to raise_error(OutOfDiskSpaceError
                                                ).with_message('The local disk is out of space')
    end
  end

  context 'when its not an image' do
    let(:pdf_url){
      'https://www.africau.edu/images/default/sample.pdf'
    }

    it 'should raise NotAnImageError' do
      downloader = ImageDownloader.new(
        url: pdf_url,
        path: '../fixtures/test_downloads'
      )
      expect{ downloader.download_and_save }.to raise_error(NotAnImageError
                                                ).with_message('This url does not point to a valid image')
    end
  end
end