class InvalidUrlError < StandardError
  def initialize(msg='The url you provided is not a valid url')
    super(msg)
  end
end