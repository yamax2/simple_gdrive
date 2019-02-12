require 'spec_helper'

RSpec.describe SimpleGdrive::Authorizer do
  let(:client_secrets_file) { 'spec/fixtures/client_secrets_stub.json' }
  let(:credential_file) { 'spec/fixtures/gdrive-reports.yaml' }

  before do
    allow(SimpleGdrive.config).to receive(:client_secrets_file).and_return(client_secrets_file)
    allow(SimpleGdrive.config).to receive(:credential_file).and_return(credential_file)
    Timecop.freeze(Time.new(2019, 2, 11, 12, 0, 1))
  end

  after { Timecop.return }

  let(:service) { described_class.new }

  context 'when credentials.json is not exists' do
    let(:client_secrets_file) { 'spec/fixtures/google_credentials_wrong.json' }

    it do
      expect { service.call }.to raise_error(Errno::ENOENT)
    end
  end

  context 'when auth request' do
    context 'and token file exists' do
      before do
        allow(service).to receive(:gets)
      end

      it do
        expect(service.call).not_to be_nil
        expect(service).not_to have_received(:gets)
      end
    end

    context 'and no token file' do
      let(:credential_file) { 'spec/fixtures/google_token_tmp.yaml' }

      before do
        FileUtils.rm_rf(credential_file)

        allow(service).to receive(:gets).and_return('token')
        allow(service).to receive(:puts)

        stub_request(
          :post, 'https://oauth2.googleapis.com/token'
        ).to_return(
          body: '{"access_token": "token", "token_type": "Bearer", "expires_in": 3600}',
          headers: {'Content-Type' => 'application/json'}
        )
      end

      context 'and rails console' do
        before { stub_const('Rails::Console', Class.new) }

        subject { service.call }

        it do
          expect { subject }.to change { File.exist?(credential_file) }.from(false).to(true)
          expect(service).to have_received(:gets)
          is_expected.not_to be_nil
        end
      end

      context 'and not in console mode' do
        it do
          expect(service.call).to be_nil
          expect(service).not_to have_received(:gets)
        end
      end

      after { FileUtils.rm_rf(credential_file) }
    end
  end
end
