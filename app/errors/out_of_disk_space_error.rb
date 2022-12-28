class OutOfDiskSpaceError < StandardError
  def initialize(msg= 'The local disk is out of space')
    super(msg)
  end
end