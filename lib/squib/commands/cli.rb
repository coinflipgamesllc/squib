require 'mercenary'
require_relative 'make_sprue'
require_relative 'new'
require_relative 'watch'

module Squib
  class CLI

    def run
      Mercenary.program(:squib) do |p|
        p.version Squib::VERSION
        p.description 'A Ruby DSL for prototyping card games'
        p.syntax 'squib <subcommand> [options]'

        p.command(:new) do |c|
          c.syntax 'new PATH'
          c.description 'Creates a new basic Squib project scaffolding in PATH. Must be a new directory or already empty.'

          c.option 'advanced', '--advanced', 'Create the advanced layout'

          c.action do |args, options|
            advanced = options.key? 'advanced'
            Squib::Commands::New.new.process(args, advanced)
          end
        end

        p.command(:make_sprue) do |c|
          c.syntax 'make_sprue'
          c.description 'Creates a sprue definition file.'

          c.action do |args, options|
            Squib::Commands::MakeSprue.new.process(args)
          end
        end

        p.command(:watch) do |c|
          c.syntax 'watch DECK_FILE [options]'
          c.description 'Runs a deck in persistent watch mode, rebuilding on file changes.'

          c.option 'dir', '--dir DIR', 'Root directory to watch (defaults to the deck file directory)'
          c.option 'ignore', '--ignore REGEX', 'Additional ignore pattern (regex). Can be supplied multiple times.'

          c.action do |args, options|
            begin
              Squib::Commands::Watch.new.process(args, options)
            rescue ArgumentError => e
              Squib.logger.error(e.message)
              exit 1
            end
          end
        end

      end
    end

  end
end
