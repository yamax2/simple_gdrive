require 'spec_helper'

RSpec.describe SimpleGdrive::Uploader do
  let(:credential_file) { 'spec/fixtures/gdrive-reports.yaml' }
  let(:client_secrets_file) { 'spec/fixtures/client_secrets_stub.json' }

  before do
    Timecop.freeze(Time.new(2019, 2, 11, 12, 0, 1))
    allow(SimpleGdrive.config).to receive(:client_secrets_file).and_return(client_secrets_file)
    allow(SimpleGdrive.config).to receive(:credential_file).and_return(credential_file)
  end

  after { Timecop.return }

  let(:uploader) { described_class.new(base_folder_id: '14lJD-WCxgCd9JxkBnsJktXhw0XrwrsLD') }
  let(:google_service) { uploader.instance_variable_get(:@service) }

  before do
    stub_request(
      :post, 'https://oauth2.googleapis.com/token'
    ).to_return(
      body: '{"access_token": "token", "token_type": "Bearer", "expires_in": 3600}',
      headers: {'Content-Type' => 'application/json'}
    )

    uploader.send(:service)
    allow(google_service).to receive(:create_file).and_call_original
  end

  context 'when first time uploading' do
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
      expect(google_service).to have_received(:create_file).exactly(5).times
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
      expect(google_service).to have_received(:create_file).once
    end
  end
end
