require 'securerandom'
require 'set'
require 'bigdecimal'
require 'bigdecimal/util'
require 'fileutils'

require_relative "vv/gem_methods"

Gem.require_files "vv/*.rb"
Gem.require_files "vv/style/*.rb"
Gem.require_files "vv/utility/*.rb"

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

class Random
  include VV::RandomMethods
  extend  VV::RandomClassSettings
end
