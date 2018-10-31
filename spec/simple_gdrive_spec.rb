require 'spec_helper'

RSpec.describe SimpleGdrive do
  it 'has a version number' do
    expect(SimpleGdrive::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'yields a config object' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class::Config)
    end
  end

  describe '.upload' do
    let(:uploader) { instance_double(SimpleGdrive::Uploader) }

    before do
      allow(SimpleGdrive::Uploader).to receive(:new).and_return(uploader)
      allow(uploader).to receive(:call)

      described_class.upload 'dir/my/test.csv', 'test.csv'
    end

    it 'calls uploader' do
      expect(uploader).to have_received(:call)
    end
  end

  describe '.clear' do
    let(:cleaner) { instance_double(SimpleGdrive::Cleaner) }

    before do
      allow(SimpleGdrive::Cleaner).to receive(:new).and_return(cleaner)
      allow(cleaner).to receive(:call)

      described_class.clear
    end

    it 'calls cleaner' do
      expect(cleaner).to have_received(:call)
    end
  end
end
