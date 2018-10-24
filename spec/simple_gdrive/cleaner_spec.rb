require 'spec_helper'

RSpec.describe SimpleGdrive::Cleaner do
  let(:credential_file) { 'spec/fixtures/gdrive-reports.yaml' }
  let(:service) { uploader.instance_variable_get(:@service) }

  describe '#call' do
    let(:cleaner) do
      described_class.new(
        app_name: 'My app',
        base_folder_id: '14lJD-WCxgCd9JxkBnsJktXhw0XrwrsLD',
        credential_file: credential_file,
        client_secrets_file: 'spec/fixtures/client_secrets_stub.json'
      )
    end

    context 'when credential file exists' do
      context 'when no files in folder' do

      end

      context 'when one page' do

      end

      context 'when multiple pages' do

      end

      context 'when folder does not exist' do

      end

      context 'when includes subfolder' do

      end
    end

    context 'when credentials file not exists' do

    end
  end
end
