# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/sync/all/sync.rbi
#
# sync-0.5.0

module Sync_m
  def initialize(*args); end
  def self.append_features(cl); end
  def self.define_aliases(cl); end
  def self.extend_object(obj); end
  def sync_ex_count; end
  def sync_ex_count=(arg0); end
  def sync_ex_locker; end
  def sync_ex_locker=(arg0); end
  def sync_exclusive?; end
  def sync_extend; end
  def sync_initialize; end
  def sync_inspect; end
  def sync_lock(m = nil); end
  def sync_locked?; end
  def sync_mode; end
  def sync_mode=(arg0); end
  def sync_sh_locker; end
  def sync_sh_locker=(arg0); end
  def sync_shared?; end
  def sync_synchronize(mode = nil); end
  def sync_try_lock(mode = nil); end
  def sync_try_lock_sub(m); end
  def sync_unlock(m = nil); end
  def sync_upgrade_waiting; end
  def sync_upgrade_waiting=(arg0); end
  def sync_waiting; end
  def sync_waiting=(arg0); end
end
class Sync_m::Err < StandardError
  def self.Fail(*opt); end
end
class Sync_m::Err::UnknownLocker < Sync_m::Err
  def self.Fail(th); end
end
class Sync_m::Err::LockModeFailer < Sync_m::Err
  def self.Fail(mode); end
end
class Sync
  def exclusive?; end
  def lock(m = nil); end
  def locked?; end
  def shared?; end
  def synchronize(mode = nil); end
  def try_lock(mode = nil); end
  def unlock(m = nil); end
  include Sync_m
end
