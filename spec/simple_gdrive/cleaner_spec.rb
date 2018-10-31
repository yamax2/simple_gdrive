require 'spec_helper'

RSpec.describe SimpleGdrive::Cleaner do
  let(:credential_file) { 'spec/fixtures/gdrive-reports.yaml' }
  let(:folder_id) { '1sEQxAl884h7yaJH2AG9qDc96JZgw5lVP' }

  describe '#call' do
    let(:cleaner) do
      described_class.new(
        app_name: 'My app',
        base_folder_id: folder_id,
        credential_file: credential_file,
        client_secrets_file: 'spec/fixtures/client_secrets_stub.json'
      )
    end

    context 'when credential file exists' do
      let(:service) { cleaner.instance_variable_get(:@service) }

      before do
        stub_request(
          :post, 'https://oauth2.googleapis.com/token'
        ).to_return(
          body: '{"access_token": "token", "token_type": "Bearer", "expires_in": 3600}',
          headers: {'Content-Type' => 'application/json'}
        )

        cleaner.send(:service)
        allow(service).to receive(:delete_file).and_call_original
      end

      context 'when no files in folder' do
        subject { VCR.use_cassette('clear_empty_dir') { cleaner.call } }

        it 'does nothing' do
          expect(subject).to be_empty
          expect(service).not_to have_received(:delete_file)
        end
      end

      context 'when one page' do
        subject { VCR.use_cassette('clear_some_files') { cleaner.call } }

        it 'deletes 2 files' do
          expect(subject).to match_array %w[1 2]
          expect(service).to have_received(:delete_file).twice
        end
      end

      context 'when multiple pages' do
        let!(:folder_id) { '0BzUkuFsHnUS7OFZ2ZmFZMnl3clE' }
        subject { VCR.use_cassette('clear_134_files') { cleaner.call } }

        it 'deletes all' do
          expect(subject.size).to eq 134
          expect(service).to have_received(:delete_file).exactly(134).times
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
          expect(subject).to match_array %w[folder 12]
          expect(service).to have_received(:delete_file).twice
        end
      end
    end

    context 'when credentials file not exists' do
      let(:credential_file) { 'spec/fixtures/test/my/gdrive-reports-new.yaml' }

      before { FileUtils.rm_rf('spec/fixtures/test') }
      after  { FileUtils.rm_rf('spec/fixtures/test') }

      subject do
        VCR.use_cassette('clear_without_credentials') { cleaner.call }
      end

      before do
        allow(cleaner).to receive(:puts)
        allow(cleaner).to receive(:gets).and_return('value')
      end

      it 'creates a new file and asks for a code' do
        expect { subject }.to raise_error(Signet::AuthorizationError)
        expect(File.exist?(credential_file)).to be_truthy
        expect(cleaner).to have_received(:gets).once
      end
    end
  end
end
