require 'simple_gdrive/version'
require 'simple_gdrive/base'
require 'simple_gdrive/uploader'
require 'simple_gdrive/cleaner'

module SimpleGdrive
  Config = Struct.new(
    :base_folder_id,
    :app_name,
    :client_secrets_file,
    :credential_file
  )

  def self.config
    @config ||= Config.new.tap do |config|
      config.base_folder_id = '14lJD-WCxgCd9JxkBnsJktXhw0XrwrsLD'
      config.app_name = 'GDrive Simple Uploader'
      config.client_secrets_file = 'client_secrets.json'
      config.credential_file = File.join(
        Dir.home,
        '.credentials',
        'gdrive-uploader.yaml'
      )
    end
  end

  def self.configure
    yield config
  end

  def self.upload(full_filename, upload_source, content_type: 'text/plain', mime_type: nil)
    Uploader.new(
      app_name: config.app_name,
      base_folder_id: config.base_folder_id,
      credential_file: config.credential_file,
      client_secrets_file: config.client_secrets_file
    ).call(full_filename, upload_source, content_type: content_type, mime_type: mime_type)
  end

  def self.clear
    Cleaner.new(
      app_name: config.app_name,
      base_folder_id: config.base_folder_id,
      credential_file: config.credential_file,
      client_secrets_file: config.client_secrets_file
    ).call
  end
end
