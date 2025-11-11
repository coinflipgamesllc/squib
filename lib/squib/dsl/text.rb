require 'digest'
require_relative '../args/box'
require_relative '../args/card_range'
require_relative '../args/draw'
require_relative '../args/paragraph'
require_relative '../args/transform'
require_relative '../dsl/text_embed'
require_relative '../errors_warnings/warn_unexpected_params'
require_relative '../watch/render_registry'

module Squib
  class Deck
    def text(opts = {})
      embed = TextEmbed.new self, __callee__
      yield(embed) if block_given? # store the opts for later use
      DSL::Text.new(self, __callee__, embed).run(opts)
    end
  end

  module DSL
    class Text
      include WarnUnexpectedParams
      attr_reader :dsl_method, :deck, :embed

      def initialize(deck, dsl_method, embed)
        @deck = deck
        @dsl_method = dsl_method
        @embed = embed
      end

      def self.accepted_params
        %i(
          str font font_size x y markup width height
          wrap spacing align justify valign ellipsize angle dash cap join
          hint color fill_color
          stroke_color stroke_width stroke_width stroke_color stroke_strategy
          range layout
        )
      end

      def run(opts)
        warn_if_unexpected opts
        range = Args.extract_range opts, deck
        para  = Args.extract_para opts, deck
        box   = Args.extract_box opts, deck, { width: :auto, height: :auto }
        trans = Args.extract_transform opts, deck
        draw  = Args.extract_draw opts, deck, { stroke_width: 0.0 }
        extents = Array.new(deck.size)
        range.each do |i|
          fingerprint, details = fingerprint_for(para[i], box[i], trans[i], draw[i], embed)
          unless Squib::Watch::RenderRegistry.skip?(dsl_method, i, fingerprint, details)
            deck.cards[i].text(embed, para[i], box[i], trans[i], draw[i], deck.dpi)
          end
          extents[i] = nil
        end
        return extents
      end

      private

      def fingerprint_for(para, box, trans, draw, embed)
        info = {
          para: safe_dump(para.to_h),
          box: safe_dump(box),
          transform: safe_dump(trans),
          draw: safe_dump(draw),
          embed_keys: embed.rules.keys.map do |key|
            rule = embed.rules[key]
            {
              key: key,
              type: rule[:type],
              files: rule[:file].map { |f| file_info(f) },
              data: rule[:svg_args]&.data&.map { |d| d ? Digest::SHA256.hexdigest(d.to_s) : nil }
            }
          end
        }
        serialized = Marshal.dump(info)
        [Digest::SHA256.hexdigest(serialized), info]
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

      def file_info(file_arg)
        return nil if file_arg.nil?

        path = file_arg.file
        return path unless path && File.exist?(path)

        [path, File.mtime(path).to_i]
      end
    end
  end
end
