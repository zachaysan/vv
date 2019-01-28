class Bold

  def code
    "\033[1m"
  end

  def unbold
    "\033[21m"
  end

  def uncode
    self.unbold
  end

end
