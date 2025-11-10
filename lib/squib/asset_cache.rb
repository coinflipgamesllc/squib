require 'thread'

module Squib
  module AssetCache
    CacheEntry = Struct.new(:value, :version) do
      def fresh?(current_version)
        return true if current_version.nil?
        version == current_version
      end
    end

    class InMemory
      def initialize
        @entries = {}
        @lock = Mutex.new
      end

      def fetch(key, version: nil, &loader)
        raise ArgumentError, 'block required' unless block_given?

        @lock.synchronize do
          entry = @entries[key]
          return entry.value if entry && entry_fresh?(entry, key, version)

          value = loader.call
          new_version = normalized_version(version || compute_version(key))
          @entries[key] = CacheEntry.new(value, new_version)
        end

        @entries[key]&.value
      end

      def fetch_png(path, &loader)
        loader ||= proc { Squib.open_png(path) }
        fetch(path, &loader)
      end

      def invalidate!(key = nil)
        @lock.synchronize do
          key.nil? ? @entries.clear : @entries.delete(key)
        end
      end

      private

      def compute_version(path)
        return nil unless File.exist?(path)
        File.mtime(path).to_f
      end

      def entry_fresh?(entry, key, override_version)
        current_version = normalized_version(override_version || compute_version(key))
        entry.fresh?(current_version)
      end

      def normalized_version(input)
        input&.to_f
      end
    end
  end

  def asset_cache
    @asset_cache ||= AssetCache::InMemory.new
  end
  module_function :asset_cache

  def asset_cache=(cache)
    @asset_cache = cache
  end
  module_function :asset_cache=
end

