require 'spec_helper'
require 'tempfile'
require 'securerandom'

RSpec.describe Squib::AssetCache::InMemory do
  let(:cache) { described_class.new }
  let(:tmp_file) do
    Tempfile.new(['squib-asset-cache', '.png']).tap do |f|
      f.write('png-data')
      f.flush
    end
  end

  after do
    tmp_file.close!
  end

  it 'returns cached values while the source has not changed' do
    load_count = 0
    loader = proc do
      load_count += 1
      :loaded_surface
    end

    first = cache.fetch(tmp_file.path, &loader)
    second = cache.fetch(tmp_file.path, &loader)

    expect(first).to eq(:loaded_surface)
    expect(second).to eq(:loaded_surface)
    expect(load_count).to eq(1)
  end

  it 'reloads when the source file mtime changes' do
    values = [:initial_surface, :reloaded_surface]
    loader = proc { values.shift }

    original = cache.fetch(tmp_file.path, &loader)
    # Touch the file to advance mtime
    File.write(tmp_file.path, 'png-data-updated')
    File.utime(Time.now + 1, Time.now + 1, tmp_file.path)

    reloaded = cache.fetch(tmp_file.path, &loader)

    expect(original).to eq(:initial_surface)
    expect(reloaded).to eq(:reloaded_surface)
  end

  it 'can invalidate a single entry explicitly' do
    loader = proc { SecureRandom.uuid }

    cached = cache.fetch(tmp_file.path, &loader)
    cache.invalidate!(tmp_file.path)
    reloaded = cache.fetch(tmp_file.path, &loader)

    expect(reloaded).not_to eq(cached)
  end
end

