require 'digest'
require_relative '../errors_warnings/warn_unexpected_params'
require_relative '../args/card_range'
require_relative '../args/paint'
require_relative '../args/scale_box'
require_relative '../args/transform'
require_relative '../args/input_file'
require_relative '../watch/render_registry'

module Squib
  class Deck
    def png(opts = {})
      DSL::PNG.new(self, __callee__).run(opts)
    end
  end

  module DSL
    class PNG
      include WarnUnexpectedParams
      attr_reader :dsl_method, :deck

      def initialize(deck, dsl_method)
        @deck = deck
        @dsl_method = dsl_method
      end

      def self.accepted_params
        %i(
          file
          x y width height
          alpha blend mask angle
          crop_x crop_y crop_width crop_height
          crop_corner_radius crop_corner_x_radius crop_corner_y_radius
          flip_horizontal flip_vertical
          range layout
          placeholder
         )
      end

      def run(opts)
        warn_if_unexpected opts
        Dir.chdir(deck.img_dir) do
          range = Args.extract_range opts, deck
          paint = Args.extract_paint opts, deck
          box   = Args.extract_scale_box opts, deck
          trans = Args.extract_transform opts, deck
          ifile = Args.extract_input_file opts, deck
          deck.progress_bar.start('Loading PNG(s)', range.size) do |bar|
            range.each do |i|
              fingerprint, details = fingerprint_for(ifile[i], box[i], paint[i], trans[i])
              if Squib::Watch::RenderRegistry.skip?(dsl_method, i, fingerprint, details)
                bar.increment
                next
              end
              deck.cards[i].png(ifile[i].file, box[i], paint[i], trans[i])
              bar.increment
            end
          end
        end

      end

      private

      def fingerprint_for(input_file_arg, box_arg, paint_arg, trans_arg)
        file = input_file_arg.file
        placeholder = input_file_arg.respond_to?(:placeholder) ? input_file_arg.placeholder : nil
        file_mtime = if file && File.exist?(file)
                       File.mtime(file).to_i
                     end
        data = [
          file,
          file_mtime,
          placeholder,
          safe_dump(box_arg),
          safe_dump(paint_arg),
          safe_dump(trans_arg)
        ]
        serialized = Marshal.dump(data)
        warn "fingerprint data: #{data.inspect}" if ENV['SQUIB_DEBUG_FP'] == '1'
        [Digest::SHA256.hexdigest(serialized), data]
      rescue TypeError
        digest = Digest::SHA256.hexdigest(data.inspect)
        [digest, data]
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
