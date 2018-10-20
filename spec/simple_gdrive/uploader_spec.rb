require 'spec_helper'

RSpec.describe SimpleGdrive::Uploader do
  describe '#call' do
    let(:uploader) do
      described_class.new(
        app_name: 'My app',
        base_folder_id: '14lJD-WCxgCd9JxkBnsJktXhw0XrwrsLD',
        credential_file: credential_file,
        client_secrets_file: 'spec/fixtures/client_secrets_stub.json'
      )
    end

    let(:credential_file) { 'spec/fixtures/gdrive-reports.yaml' }
    let(:service) { uploader.instance_variable_get(:@service) }

    context 'when credential file exists' do
      before do
        stub_request(
          :post, 'https://oauth2.googleapis.com/token'
        ).to_return(
          body: '{"access_token": "token", "token_type": "Bearer", "expires_in": 3600}',
          headers: {'Content-Type' => 'application/json'}
        )
      end

      before do
        uploader.send(:service)
        allow(service).to receive(:create_file).and_call_original
      end

      context 'when when first time uploading' do
        subject do
          VCR.use_cassette('first_time_upload') do
            uploader.call(
              'My/First/Dir/2018/Gemfile',
              'Gemfile',
              content_type: 'text/plain'
            )
          end
        end

        it 'uploads file and creates folders' do
          is_expected.to include(:id, :parent_id)
          expect(service).to have_received(:create_file).exactly(5).times
        end
      end

      context 'when uploading to existed folder' do
        subject do
          VCR.use_cassette('second_time_upload') do
            uploader.call('My/First/Dir/2018/Gemfile.lock', 'Gemfile.lock', content_type: 'text/plain')
          end
        end

        it 'uploads file only' do
          is_expected.to include(:id, :parent_id)
          expect(service).to have_received(:create_file).once
        end
      end
    end

    context 'when credentials file not exists' do
      let(:credential_file) { 'spec/fixtures/test/my/gdrive-reports-new.yaml' }

      before { FileUtils.rm_rf('spec/fixtures/test') }
      after  { FileUtils.rm_rf('spec/fixtures/test') }

      subject do
        VCR.use_cassette('upload_without_credentials') do
          uploader.call(
            'My/First/Dir/2018/Gemfile.lock',
            'Gemfile.lock',
            content_type: 'text/plain'
          )
        end
      end

      before do
        allow(uploader).to receive(:puts)
        allow(uploader).to receive(:gets).and_return('value')
      end

      it 'creates a new file and asks for code' do
        expect { subject }.to raise_error(Signet::AuthorizationError)
        expect(File.exist?(credential_file)).to be_truthy
        expect(uploader).to have_received(:gets).once
      end
    end
  end
end
