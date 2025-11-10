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

  describe '#fetch_text' do
    it 'avoids re-reading unchanged files' do
      text_file = Tempfile.new(['squib-cache', '.txt'])
      text_file.write('hello world')
      text_file.flush

      expect(File).to receive(:read).once.with(text_file.path, mode: 'r:UTF-8').and_call_original
      cache.fetch_text(text_file.path)
      cache.fetch_text(text_file.path)

      text_file.close!
    end
  end

  describe '#fetch_binary' do
    it 'avoids re-reading unchanged binary files' do
      bin_file = Tempfile.new(['squib-cache', '.bin'])
      bin_file.write('bin')
      bin_file.flush

      expect(File).to receive(:binread).once.with(bin_file.path).and_call_original
      cache.fetch_binary(bin_file.path)
      cache.fetch_binary(bin_file.path)

      bin_file.close!
    end
  end

  describe '#fetch_string' do
    it 'caches derived values based on string content' do
      load_count = 0
      value = cache.fetch_string(:csv_data, "foo\nbar") do
        load_count += 1
        :parsed
      end

      again = cache.fetch_string(:csv_data, "foo\nbar") { :another }

      expect(value).to eq(:parsed)
      expect(again).to eq(:parsed)
      expect(load_count).to eq(1)
    end
  end

  describe '#fetch_svg' do
    let(:handle) { instance_double('Rsvg::Handle') }

    before do
      unless defined?(Rsvg::Handle)
        module Rsvg; class Handle; end; end
      end
    end

    it 'caches handles loaded from disk' do
      svg_file = Tempfile.new(['squib-cache', '.svg'])
      svg_file.write('<svg/>')
      svg_file.flush

      expect(Rsvg::Handle).to receive(:new_from_data).once.and_return(handle)

      cache.fetch_svg(path: svg_file.path)
      cache.fetch_svg(path: svg_file.path)

      svg_file.close!
    end

    it 'caches handles constructed from inline data' do
      data = '<svg id="foo"/>'

      expect(Rsvg::Handle).to receive(:new_from_data).once.and_return(handle)

      cache.fetch_svg(data: data)
      cache.fetch_svg(data: data.dup)
    end
  end
end

