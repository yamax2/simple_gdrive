require 'spec_helper'

RSpec.describe SimpleGdrive::TrashCleaner do
  let(:credential_file) { 'spec/fixtures/gdrive-reports.yaml' }
  let(:client_secrets_file) { 'spec/fixtures/client_secrets_stub.json' }

  let(:trash_cleaner) { described_class.new }
  let(:google_service) { trash_cleaner.instance_variable_get(:@service) }

  before do
    Timecop.freeze(Time.new(2019, 2, 11, 12, 0, 1))

    allow(SimpleGdrive.config).to receive(:client_secrets_file).and_return(client_secrets_file)
    allow(SimpleGdrive.config).to receive(:credential_file).and_return(credential_file)

    trash_cleaner.send(:service)
    allow(google_service).to receive(:empty_file_trash).and_call_original

    VCR.use_cassette('trash_clean') { trash_cleaner.call }
  end

  after { Timecop.return }

  it 'cleans the trash bin' do
    expect(google_service).to have_received(:empty_file_trash).once
  end
end
