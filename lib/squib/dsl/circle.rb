require 'digest'
require_relative '../errors_warnings/warn_unexpected_params'
require_relative '../args/card_range'
require_relative '../args/coords'
require_relative '../args/draw'
require_relative '../watch/render_registry'

module Squib
  class Deck
    def circle(opts = {})
      DSL::Circle.new(self, __callee__).run(opts)
    end
  end

  module DSL
    class Circle
      include WarnUnexpectedParams
      attr_reader :dsl_method, :deck

      def initialize(deck, dsl_method)
        @deck = deck
        @dsl_method = dsl_method
      end

      def self.accepted_params
        %i(x y
           radius arc_start arc_end arc_direction arc_close
           fill_color stroke_color stroke_width stroke_strategy join dash cap
           range layout)
      end

      def run(opts)
        warn_if_unexpected opts
        range = Args.extract_range opts, deck
        coords = Args.extract_coords opts, deck
        draw  = Args.extract_draw opts, deck
        range.each do |i|
          fingerprint, details = fingerprint_for(coords[i], draw[i])
          next if Squib::Watch::RenderRegistry.skip?(dsl_method, i, fingerprint, details)

          deck.cards[i].circle(coords[i], draw[i])
        end
      end

      private

      def fingerprint_for(coords, draw)
        info = {
          coords: safe_dump(coords),
          draw: safe_dump(draw)
        }
        [Digest::SHA256.hexdigest(Marshal.dump(info)), info]
      rescue TypeError
        digest = Digest::SHA256.hexdigest(info.inspect)
        [digest, info]
      end

      def safe_dump(obj)
        case obj
        when NilClass, Numeric, String, Symbol, TrueClass, FalseClass
          obj
        else
          if obj.respond_to?(:to_h)
            obj.to_h.transform_values { |v| safe_dump(v) }
          elsif obj.respond_to?(:to_a)
            obj.to_a.map { |v| safe_dump(v) }
          else
            obj.to_s
          end
        end
      end
    end
  end
end
