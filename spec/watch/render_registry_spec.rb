require 'spec_helper'
require 'squib/watch/render_registry'

RSpec.describe Squib::Watch::RenderRegistry do
  before do
    described_class.reset!
  end

  it 'marks cards dirty on first run and clean on identical runs' do
    key = 'test'
    fingerprint = 'abc'
    details = %w[file 123]

    described_class.with_session(key) do
      expect(described_class.skip?(:png, 0, fingerprint, details)).to be false
    end

    described_class.with_session(key) do
      expect(described_class.skip?(:png, 0, fingerprint, details)).to be true
    end

    described_class.with_session(key) do
      expect(described_class.skip?(:png, 0, 'other', details)).to be false
    end
  end
end

