require 'fileutils'

require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

module SimpleGdrive
  class Uploader
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    USER_ID = 'default'.freeze
    FOLDER_MIME_TYPE = 'application/vnd.google-apps.folder'.freeze

    def initialize(app_name:, base_folder_id:, credential_file:, client_secrets_file:)
      @app_name = app_name
      @base_folder_id = base_folder_id
      @credential_file = credential_file
      @client_secrets_file = client_secrets_file
    end

    def call(full_filename, upload_source, content_type:)
      names = full_filename.split('/')
      filename = names.pop
      parent_id = find_folder(names)

      file = service.create_file(
        {name: filename, parents: [parent_id]},
        upload_source: upload_source,
        content_type: content_type,
        options: options
      )

      {id: file.id, parent_id: parent_id}
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
      @credentials ||= load_credentials
    end

    def find_folder(names)
      id = @base_folder_id

      names.each { |folder_name| id = find_or_create_folder(folder_name, id) }

      id
    end

    def find_or_create_folder(name, parent_id = nil)
      folder_id = parent_id || @base_folder_id

      res = service.list_files(
        q: "mimeType='#{FOLDER_MIME_TYPE}' and " \
           "name='#{name}' and '#{folder_id}' in parents and not trashed"
      )

      return res.files.first.id if res.files.any?

      service.create_file(
        {name: name, mime_type: FOLDER_MIME_TYPE, parents: [folder_id]},
        options: options
      ).id
    end

    def load_credentials
      FileUtils.mkdir_p File.dirname(@credential_file)

      client_id = Google::Auth::ClientId.from_file(@client_secrets_file)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: @credential_file)

      authorizer = Google::Auth::UserAuthorizer.new(
        client_id,
        Google::Apis::DriveV3::AUTH_DRIVE,
        token_store
      )

      credentials = authorizer.get_credentials(USER_ID)
      credentials || auth_request(authorizer)
    end

    def options
      {retries: 5}
    end

    def service
      @service ||= Google::Apis::DriveV3::DriveService.new.tap do |service|
        service.client_options.application_name = @app_name
        service.authorization = credentials
      end
    end
  end
end
