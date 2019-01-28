class Italic

  def code
    "\033[3m"
  end

  def unitalic
    "\033[23m"
  end

  def uncode
    self.unitalic
  end

end
