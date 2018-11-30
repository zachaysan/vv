require_relative "vv/gem_methods"

Gem.require_files "vv/*.rb"

class String
  include VV::StringMethods
end

class Hash
  include VV::HashMethods
end

class Array
  include VV::ArrayMethods
end

class TrueClass
  include VV::TrueMethods
end

class FalseClass
  include VV::FalseMethods
end

class NilClass
  include VV::NilMethods
end
