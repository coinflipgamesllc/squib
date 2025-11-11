require_relative 'render_registry'
require_relative 'deck_cache'

module Squib
  module Watch
    class Server
      DEFAULT_IGNORE = [
        %r{/\.git},
        %r{/_output},
        %r{/\.{1,2}$},
        %r{\.tmp$},
        %r{\.swp$}
      ].freeze

      def initialize(deck_path, options = {})
        @deck_path = File.expand_path(deck_path)
        @project_dir = options[:project_dir] ? File.expand_path(options[:project_dir]) : File.dirname(@deck_path)
        @logger = options[:logger] || Squib.logger
        ensure_logger_level!
        @ignore_patterns = DEFAULT_IGNORE + Array(options[:ignore]).compact
        @listener = nil
        @running = false
      end

      def start
        ensure_script_exists!
        ensure_project_dir!
        log_info "Starting Squib watch server for #{@deck_path}"
        run_deck
        @listener = build_listener
        trap_signals(@listener)
        @listener.start
        wait_for_interrupt
      ensure
        stop_listener
      end

      private

      def ensure_script_exists!
        return if File.exist?(@deck_path)

        raise ArgumentError, "Deck script does not exist: #{@deck_path}"
      end

      def ensure_project_dir!
        return if Dir.exist?(@project_dir)

        raise ArgumentError, "Project directory does not exist: #{@project_dir}"
      end

      def build_listener
        require_listen!
        ::Listen.to(@project_dir, ignore: @ignore_patterns) do |modified, added, removed|
          handle_change(modified + added + removed)
        end
      end

      def handle_change(paths)
        relevant = paths.map { |path| File.expand_path(path) }
                        .reject { |path| ignored_path?(path) }
        return if relevant.empty?
        return if @running

        log_info "Change detected: #{shorten_paths(relevant).join(', ')}"
        run_deck
      end

      def run_deck
        @running = true
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        log_info "Starting build: #{short_deck_path}"
        Watch::DeckCache.with_session(@deck_path) do
          Watch::RenderRegistry.with_session(@deck_path) do
            Dir.chdir(File.dirname(@deck_path)) do
              load @deck_path
            end
          end
        end
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
        log_info format('Build finished in %.2fs', elapsed)
      rescue Exception => e # rubocop:disable Lint/RescueException
        log_error "Error while building #{@deck_path}: #{e.class} - #{e.message}"
        log_error e.backtrace.join("\n") if @logger.respond_to?(:level) && @logger.level <= ::Logger::DEBUG
      ensure
        @running = false
      end

      def require_listen!
        require 'listen'
      rescue LoadError
        raise LoadError, "The 'listen' gem is required for watch mode. Install it with `gem install listen`."
      end

      def trap_signals(listener)
        %w[INT TERM].each do |sig|
          Signal.trap(sig) do
            log_info 'Stopping watch server...'
            listener.stop
            exit
          end
        end
      end

      def stop_listener
        @listener&.stop
      rescue StandardError => e
        log_error "Failed to stop listener: #{e.message}"
      end

      def wait_for_interrupt
        loop do
          sleep 1
        end
      rescue Interrupt
        log_info 'Watch server interrupted. Shutting down.'
      end

      def ignored_path?(path)
        @ignore_patterns.any? { |pattern| path.match?(pattern) }
      end

      def shorten_paths(paths)
        paths.map do |path|
          path.start_with?(@project_dir) ? path.delete_prefix("#{@project_dir}/") : path
        end
      end

      def short_deck_path
        shorten_paths([@deck_path]).first
      end

      def log_info(message)
        @logger.info(message)
      end

      def log_error(message)
        @logger.error(message)
      end

      def ensure_logger_level!
        return unless @logger.respond_to?(:level) && @logger.respond_to?(:level=)

        @logger.level = ::Logger::INFO if @logger.level > ::Logger::INFO
      end
    end
  end
end

