require_relative '../errors_warnings/warn_unexpected_params'
require_relative '../args/card_range'
require_relative '../args/paint'
require_relative '../args/scale_box'
require_relative '../args/transform'
require_relative '../args/input_file'
require_relative '../args/svg_special'

module Squib
  class Deck
    def svg(opts = {})
      DSL::SVG.new(self, __callee__).run(opts)
    end
  end

  module DSL
    class SVG
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
          blend mask
          crop_x crop_y crop_width crop_height
          crop_corner_radius crop_corner_x_radius crop_corner_y_radius
          flip_horizontal flip_vertical angle
          id force_id data
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
          svg_args = Args.extract_svg_special opts, deck
          deck.progress_bar.start('Loading SVG(s)', range.size) do |bar|
            range.each do |i|
              if svg_args.render?(i)
                fingerprint, details = fingerprint_for(ifile[i], svg_args[i], box[i], paint[i], trans[i])
                unless Squib::Watch::RenderRegistry.skip?(dsl_method, i, fingerprint, details)
                  deck.cards[i].svg(ifile[i].file, svg_args[i], box[i], paint[i],
                                    trans[i])
                end
              end
              bar.increment
            end
          end
        end

      end
      private

      def fingerprint_for(input_file_arg, svg_arg, box_arg, paint_arg, trans_arg)
        file = input_file_arg.file
        data = svg_arg.data
        file_mtime = if file && File.exist?(file)
                       File.mtime(file).to_i
                     end
        info = [
          file,
          file_mtime,
          svg_arg.id,
          svg_arg.render?,
          data ? Digest::SHA256.hexdigest(data.to_s) : nil,
          safe_dump(box_arg),
          safe_dump(paint_arg),
          safe_dump(trans_arg)
        ]
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

    end
  end
end
