require 'google/apis/drive_v3'

module SimpleGdrive
  class Base
    FOLDER_MIME_TYPE = 'application/vnd.google-apps.folder'.freeze
    OPTIONS = {retries: 5}.freeze

    def initialize(base_folder_id:)
      @base_folder_id = base_folder_id
    end

    private

    def service
      @service ||= Google::Apis::DriveV3::DriveService.new.tap do |service|
        service.client_options.application_name = SimpleGdrive.config.app_name
        service.authorization = Authorizer.call
      end
    end
  end
end
