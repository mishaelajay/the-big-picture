require 'rails_helper'

RSpec.describe ImageUrlsFileParser do
  context 'should return urls in specified batch size' do
    let(:forty_urls_filepath) { file_fixture('image_urls_40.txt').realpath }
    let(:parser_service) { ImageUrlsFileParser.new(filepath: forty_urls_filepath,
                                                  batch_size: 25) }
    it 'should return urls in batches' do
      batch_1 = parser_service.next
      expect(batch_1.count).to be parser_service.batch_size
      batch_2 = parser_service.next
      expect(batch_2.count).to be 15
      batch_3 = parser_service.next
      expect(batch_3.count).to be 0
    end

    it 'should return first batch on rewind' do
      parser_service.rewind
      rewind_batch = parser_service.next
      expect(rewind_batch.count).to be 25
    end
  end
end