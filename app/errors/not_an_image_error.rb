class NotAnImageError < StandardError
  def initialize(msg='This url does not point to a valid image')
    super(msg)
  end
end