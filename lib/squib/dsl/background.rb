require 'digest'
require_relative '../errors_warnings/warn_unexpected_params'
require_relative '../args/card_range'
require_relative '../args/draw'
require_relative '../watch/render_registry'

module Squib
  class Deck
    def background(opts = {})
      DSL::Background.new(self, __callee__).run(opts)
    end
  end

  module DSL
    class Background
      include WarnUnexpectedParams
      attr_reader :dsl_method, :deck

      def initialize(deck, dsl_method)
        @deck = deck
        @dsl_method = dsl_method
      end

      def self.accepted_params
        %i{
          range
          color
        }
      end

      def run(opts)
        warn_if_unexpected opts
        range = Args.extract_range opts, deck
        draw  = Args.extract_draw opts, deck
        range.each do |i|
          color = draw.color[i]
          fingerprint = Digest::SHA256.hexdigest([color].inspect)
          if Squib::Watch::RenderRegistry.skip?(dsl_method, i, fingerprint, color)
            next
          end
          @deck.cards[i].background(color)
        end
      end
    end
  end
end
