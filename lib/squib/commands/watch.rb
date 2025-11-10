require_relative '../watch/server'

module Squib
  module Commands
    class Watch
      def process(args, options = {})
        deck_path = args.first
        raise ArgumentError, 'You must provide the path to a deck script.' if deck_path.nil? || deck_path.strip.empty?

        absolute_deck = File.expand_path(deck_path)
        unless File.exist?(absolute_deck)
          raise ArgumentError, "Deck script not found: #{deck_path}"
        end

        project_dir = options.fetch('dir', nil)
        project_dir = File.expand_path(project_dir) unless project_dir.nil?
        project_dir ||= File.dirname(absolute_deck)

        ignore_opts = Array(options['ignore']).compact
        ignore_patterns = ignore_opts.map do |pattern|
          Regexp.new(pattern)
        rescue RegexpError => e
          raise ArgumentError, "Invalid ignore pattern '#{pattern}': #{e.message}"
        end

        server_options = {
          project_dir: project_dir,
          ignore: ignore_patterns,
          logger: Squib.logger
        }

        Squib::Watch::Server.new(absolute_deck, server_options).start
      end

      def self.run_from_argv(argv)
        options = {}
        args = []
        tokens = argv.dup
        until tokens.empty?
          token = tokens.shift
          case token
          when /\A--dir=/
            options['dir'] = token.split('=', 2).last
          when '--dir'
            next_token = tokens.shift
            options['dir'] = next_token
          when /\A--ignore=/
            options['ignore'] ||= []
            options['ignore'] << token.split('=', 2).last
          when '--ignore'
            next_token = tokens.shift
            options['ignore'] ||= []
            options['ignore'] << next_token
          else
            args << token
          end
        end
        new.process(args, options)
      end
    end
  end
end

