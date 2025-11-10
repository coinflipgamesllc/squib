require 'thread'
require 'digest'

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

      def fetch_svg(path: nil, data: nil, &loader)
        if data && (path.nil? || path.to_s.empty?)
          key = [:svg_data, Digest::SHA256.hexdigest(data)]
          loader ||= proc { Rsvg::Handle.new_from_data(data) }
          fetch(key, version: 0, &loader)
        elsif path
          loader ||= proc { Rsvg::Handle.new_from_data(File.binread(path)) }
          fetch(path, &loader)
        else
          raise ArgumentError, 'either path or data required'
        end
      end

      def fetch_text(path, &loader)
        loader ||= proc { File.read(path, mode: 'r:UTF-8') }
        key = [:text, File.expand_path(path)]
        version = compute_version(path) || 0
        fetch(key, version: version, &loader)
      end

      def fetch_binary(path, &loader)
        loader ||= proc { File.binread(path) }
        key = [:binary, File.expand_path(path)]
        version = compute_version(path) || 0
        fetch(key, version: version, &loader)
      end

      def fetch_string(key_prefix, string, &loader)
        raise ArgumentError, 'string required' if string.nil?
        key = [key_prefix, Digest::SHA256.hexdigest(string)]
        loader ||= proc { string.dup }
        fetch(key, version: 0, &loader)
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

