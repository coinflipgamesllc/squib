module Squib
  module Watch
    module RenderRegistry
      module_function

      def with_session(key)
        return yield unless key

        Thread.current[:squib_watch_render_key] = key
        ensure_store(key)
        yield
      ensure
        if key
          finalize!(key)
          Thread.current[:squib_watch_render_key] = nil
        end
      end

      def skip?(method, card_index, fingerprint, details = nil)
        key = Thread.current[:squib_watch_render_key]
        return false unless key

        data = ensure_store(key)
        entry = { fingerprint: fingerprint, details: details }
        data[:current][method][card_index] = entry
        previous_entry = data[:previous][method][card_index]
        return false unless previous_entry
        same_details = details.nil? || previous_entry[:details] == details
        same_fingerprint = previous_entry[:fingerprint] == fingerprint
        same_details && same_fingerprint
      end

      def reset!
        @store = {}
      end

      def store
        @store ||= {}
      end

      def ensure_store(key)
        store[key] ||= {
          previous: blank_method_hash,
          current: blank_method_hash
        }
      end

      def finalize!(key)
        data = store[key]
        return unless data

        new_previous = blank_method_hash
        data[:current].each do |method, cards|
          new_previous[method].merge!(cards)
        end
        data[:previous] = new_previous
        data[:current] = blank_method_hash
      end

      def blank_method_hash
        Hash.new { |h, k| h[k] = {} }
      end
    end
  end
end

