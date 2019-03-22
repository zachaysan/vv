require "json"
require "securerandom"
require "readline"
require "set"
require "bigdecimal"
require "bigdecimal/util"
require "fileutils"

require_relative "vv/gem_methods"
require_relative "vv/set_methods"

Gem.require_files "vv/*.rb"
Gem.require_files "vv/style/*.rb"
Gem.require_files "vv/utility/*.rb"
Gem.require_files "vv/serialization/*.rb"

class Object
  include VV::ObjectMethods
end

class Symbol
  include VV::SymbolMethods
end

class String
  include VV::StringMethods
end

class File
  include VV::FileMethods
end

class Hash
  include VV::HashMethods
end

class Set
  include VV::SetMethods
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

class Numeric
  include VV::NumericMethods
end

class BigDecimal
  include VV::DecimalMethods
end

class Complex
  include VV::ComplexMethods
end

class Integer
  include VV::IntegerMethods
end

class Float
  include VV::FloatMethods
end

class Random
  include VV::RandomMethods
  extend  VV::RandomClassSettings
end
