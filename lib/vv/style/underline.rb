class Underline

  def code
    "\033[4m"
  end

  def off
    "\033[24m"
  end
  alias_method :underline_off, :off

  def uncode
    off
  end

end
