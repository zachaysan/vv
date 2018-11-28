Dir["lib/vv/*.rb"].each do |filepath|
  require filepath["lib/".size..-1].chomp(".rb")
end

class String
  include VV::StringMethods
end

class Readline
  include VV::ReadlineMethods
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
