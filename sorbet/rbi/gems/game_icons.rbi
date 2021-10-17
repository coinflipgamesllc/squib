# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/game_icons/all/game_icons.rbi
#
# game_icons-0.45.0.20210930

module GameIcons
  def self.get(name); end
  def self.names; end
end
class GameIcons::DB
  def self.files; end
  def self.init; end
  def self.names; end
end
class GameIcons::OptionalDeps
  def self.require_nokogiri; end
end
class GameIcons::Icon
  def correct_pathdata; end
  def file; end
  def initialize(file); end
  def recolor(bg: nil, fg: nil, bg_opacity: nil, fg_opacity: nil); end
  def string; end
end
class GameIcons::DidYouMean
  def char_freq(str); end
  def initialize(names); end
  def lex(names); end
  def query(q, result_size = nil); end
  def score(n_freq, q_freq); end
  def scrub(str); end
  def top(n, scores); end
end
class GameIcons::Finder
  def find(icon); end
  def not_found(str, orig_str); end
end
