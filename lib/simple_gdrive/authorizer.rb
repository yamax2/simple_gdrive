require 'fileutils'

require 'google/apis/drive_v3'
require 'googleauth/stores/file_token_store'

module SimpleGdrive
  class Authorizer
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    DEFAULT_USER_ID = 'default'.freeze
    API_SCOPE = [Google::Apis::DriveV3::AUTH_DRIVE].freeze

    def call
      FileUtils.mkdir_p File.dirname(::SimpleGdrive.config.credential_file)

      credentials = user_authorizer.get_credentials(DEFAULT_USER_ID)
      credentials = request_credentials if credentials.nil? && defined?(Rails::Console)

      credentials
    end

    def self.call
      new.call
    end

    private

    def user_authorizer
      return @user_authorizer if defined?(@user_authorizer)

      client_id = ::Google::Auth::ClientId.from_file(::SimpleGdrive.config.client_secrets_file)
      token_store = ::Google::Auth::Stores::FileTokenStore.new(file: ::SimpleGdrive.config.credential_file)

      @user_authorizer = ::Google::Auth::UserAuthorizer.new(
        client_id,
        API_SCOPE,
        token_store,
        OOB_URI
      )
    end

    def request_credentials
      puts 'Open the following URL in the browser and enter the '\
           "resulting code after authorization:\n#{user_authorizer.get_authorization_url}"

      user_authorizer.get_and_store_credentials_from_code(
        user_id: DEFAULT_USER_ID,
        code: gets
      )
    end
  end
end
