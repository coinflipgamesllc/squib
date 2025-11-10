require 'spec_helper'
require 'squib/commands/watch'

RSpec.describe Squib::Commands::Watch do
  let(:logger) { Logger.new(StringIO.new) }
  let(:command) { described_class.new }

  before do
    allow(Squib).to receive(:logger).and_return(logger)
  end

  describe '#process' do
    it 'raises when no deck path is provided' do
      expect { command.process([], {}) }.to raise_error(ArgumentError)
    end

    it 'raises when the deck path does not exist' do
      expect { command.process(['missing.rb'], {}) }.to raise_error(ArgumentError)
    end

    it 'starts the watch server with resolved paths' do
      Dir.mktmpdir do |dir|
        deck = File.join(dir, 'deck.rb')
        File.write(deck, '')
        server = instance_double(Squib::Watch::Server, start: nil)
        expect(Squib::Watch::Server).to receive(:new).with(File.expand_path(deck), hash_including(project_dir: File.expand_path(dir))).and_return(server)
        command.process([deck], {})
      end
    end
  end
end

