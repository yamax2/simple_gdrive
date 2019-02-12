require 'spec_helper'

RSpec.describe SimpleGdrive::Cleaner do
  let(:credential_file) { 'spec/fixtures/gdrive-reports.yaml' }
  let(:client_secrets_file) { 'spec/fixtures/client_secrets_stub.json' }
  let(:folder_id) { '1sEQxAl884h7yaJH2AG9qDc96JZgw5lVP' }

  let(:cleaner) { described_class.new(base_folder_id: folder_id) }
  let(:google_service) { cleaner.instance_variable_get(:@service) }

  before do
    Timecop.freeze(Time.new(2019, 2, 11, 12, 0, 1))

    allow(SimpleGdrive.config).to receive(:client_secrets_file).and_return(client_secrets_file)
    allow(SimpleGdrive.config).to receive(:credential_file).and_return(credential_file)

    stub_request(
      :post, 'https://oauth2.googleapis.com/token'
    ).to_return(
      body: '{"access_token": "token", "token_type": "Bearer", "expires_in": 3600}',
      headers: {'Content-Type' => 'application/json'}
    )

    cleaner.send(:service)
    allow(google_service).to receive(:delete_file).and_call_original
  end

  after { Timecop.return }

  context 'when no files in folder' do
    subject { VCR.use_cassette('clear_empty_dir') { cleaner.call } }

    it 'does nothing' do
      is_expected.to be_empty
      expect(google_service).not_to have_received(:delete_file)
    end
  end

  context 'when one page' do
    subject { VCR.use_cassette('clear_some_files') { cleaner.call } }

    it 'deletes 2 files' do
      is_expected.to match_array %w[1 2]
      expect(google_service).to have_received(:delete_file).twice
    end
  end

  context 'when multiple pages' do
    let!(:folder_id) { '0BzUkuFsHnUS7OFZ2ZmFZMnl3clE' }
    subject { VCR.use_cassette('clear_134_files') { cleaner.call } }

    it 'deletes all' do
      expect(subject.size).to eq 134
      expect(google_service).to have_received(:delete_file).exactly(134).times
    end
  end

  context 'when folder does not exist' do
    let!(:folder_id) { 'zozo' }

    subject { VCR.use_cassette('clear_wrong_folder') { cleaner.call } }

    it 'raises an error' do
      expect { subject }.to raise_error(Google::Apis::ClientError)
    end
  end

  context 'when includes subfolder' do
    subject { VCR.use_cassette('clear_file_and_folder') { cleaner.call } }

    it 'deletes both file and folder' do
      is_expected.to match_array %w[folder 12]
      expect(google_service).to have_received(:delete_file).twice
    end
  end
end
