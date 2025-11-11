module Squib
  module Watch
    module DeckCache
      module_function

      def with_session(key)
        return yield unless key

        Thread.current[:squib_watch_deck_key] = key
        ensure_store(key)
        yield
      ensure
        if key
          store[key][:previous] = store[key][:current] || []
          store[key][:current] = []
        end
        Thread.current[:squib_watch_deck_key] = nil
      end

      def register(cards)
        key = Thread.current[:squib_watch_deck_key]
        return unless key

        store[key][:current] = cards.map(&:snapshot_surface)
      end

      def previous_surfaces
        key = Thread.current[:squib_watch_deck_key]
        return [] unless key

        store[key][:previous] || []
      end

      def active?
        !Thread.current[:squib_watch_deck_key].nil?
      end

      def reset!
        @store = {}
      end

      def ensure_store(key)
        store[key] ||= { previous: [], current: [] }
      end

      def store
        @store ||= {}
      end
    end
  end
end

