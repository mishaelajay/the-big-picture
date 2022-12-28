class ImageTooBigError < StandardError
  def initialize(msg='This image is larger than the max size passed by you')
    super(msg)
  end
end