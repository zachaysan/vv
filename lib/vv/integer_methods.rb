class Integer

  def spaces
    ( self > 0 ) ? ( " " * self ) : String.empty_string
  end

  def to_i!
    self
  end

end
