require 'spec_helper'
require 'squib/watch/server'

RSpec.describe Squib::Watch::Server do
  let(:logger_io) { StringIO.new }
  let(:logger) { Logger.new(logger_io) }

  describe '#start' do
    it 'runs the deck once and starts the listener' do
      Dir.mktmpdir do |dir|
        deck_path = File.join(dir, 'deck.rb')
        output_path = File.join(dir, 'ran.txt')
        File.write(deck_path, "File.write('#{output_path}', 'ran', mode: 'a')\n")

        listener = instance_double('Listen::Listener', start: nil, stop: nil)
        listen_module = Module.new
        listen_module.define_singleton_method(:to) do |_path, _opts, &block|
          @change_block = block
          listener
        end
        stub_const('Listen', listen_module)
        allow(listener).to receive(:start)
        allow(listener).to receive(:stop)

        server = described_class.new(deck_path, logger: logger)
        allow(server).to receive(:require_listen!)
        allow(server).to receive(:trap_signals)
        allow(server).to receive(:wait_for_interrupt) do
          server.send(:handle_change, [deck_path])
        end

        server.start

        expect(File.exist?(output_path)).to be(true)
        expect(listener).to have_received(:start)
        expect(listener).to have_received(:stop)
      end
    end
  end

  describe '#handle_change' do
    it 'debounces repeated builds when already running' do
      Dir.mktmpdir do |dir|
        deck_path = File.join(dir, 'deck.rb')
        File.write(deck_path, '')
        server = described_class.new(deck_path, logger: logger)
        allow(server).to receive(:run_deck)
        server.instance_variable_set(:@running, true)
        server.send(:handle_change, [deck_path])
        expect(server).not_to have_received(:run_deck)
      end
    end
  end
end

