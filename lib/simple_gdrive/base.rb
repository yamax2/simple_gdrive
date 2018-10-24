require 'fileutils'

require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

module SimpleGdrive
  class Base
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    USER_ID = 'default'.freeze
    FOLDER_MIME_TYPE = 'application/vnd.google-apps.folder'.freeze
    OPTIONS = {retries: 5}.freeze

    def initialize(app_name:, base_folder_id:, credential_file:, client_secrets_file:)
      @app_name = app_name
      @base_folder_id = base_folder_id
      @credential_file = credential_file
      @client_secrets_file = client_secrets_file
    end

    def service
      @service ||= Google::Apis::DriveV3::DriveService.new.tap do |service|
        service.client_options.application_name = @app_name
        service.authorization = credentials
      end
    end

    private

    def auth_request(authorizer)
      url = authorizer.get_authorization_url(base_url: OOB_URI)

      puts 'Open the following URL in the browser and enter the '\
            'resulting code after authorization'

      puts url
      code = gets

      authorizer.get_and_store_credentials_from_code(
        user_id: USER_ID,
        code: code,
        base_url: OOB_URI
      )
    end

    def credentials
      return @credentials if defined?(@credentials)

      FileUtils.mkdir_p File.dirname(@credential_file)

      client_id = Google::Auth::ClientId.from_file(@client_secrets_file)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: @credential_file)

      authorizer = Google::Auth::UserAuthorizer.new(
        client_id,
        Google::Apis::DriveV3::AUTH_DRIVE,
        token_store
      )

      @credentials = authorizer.get_credentials(USER_ID) || auth_request(authorizer)
    end
  end
end
