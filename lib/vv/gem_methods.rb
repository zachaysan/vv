module Gem

  # dirname is almost always __dir__
  def require_files pattern, dirname:
    glob = File.join dirname, pattern
    Gem.find_files(glob).each do |filepath|
      start = dirname.size + 1
      ruby_require_path = filepath[start..-1]
      if block_given?
        yield ruby_require_path
      else
        require ruby_require_path
      end
    end
  end
  module_function :require_files

end
