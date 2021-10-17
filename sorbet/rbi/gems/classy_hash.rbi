# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/classy_hash/all/classy_hash.rbi
#
# classy_hash-1.0.0

module ClassyHash
  def self.add_error(raise_errors, errors, parent_path, key, constraint, value); end
  def self.check_multi(value, constraints, strict: nil, full: nil, verbose: nil, raise_errors: nil, parent_path: nil, key: nil, errors: nil); end
  def self.constraint_string(constraint, value); end
  def self.join_path(parent_path, key); end
  def self.validate(value, constraint, strict: nil, full: nil, verbose: nil, raise_errors: nil, errors: nil, parent_path: nil, key: nil); end
  def self.validate_strict(hash, schema, verbose = nil, parent_path = nil); end
end
module ClassyHash::Generate
  def self.all(*constraints); end
  def self.array_length(length, *constraints); end
  def self.enum(*args); end
  def self.length(length); end
  def self.not(*constraints); end
  def self.string_length(length); end
end
class ClassyHash::Generate::Composite
  def constraints; end
  def describe(value); end
  def initialize(constraints, negate = nil); end
  def negate; end
end
class ClassyHash::SchemaViolationError < StandardError
  def entries; end
  def initialize(errors = nil); end
  def to_s; end
end
