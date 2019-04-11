module SimpleGdrive
  # Uploads file
  class Uploader < Base
    FOLDER_MIME_TYPE = 'application/vnd.google-apps.folder'.freeze
    OPTIONS = {retries: 5}.freeze

    def initialize(base_folder_id:)
      @base_folder_id = base_folder_id
    end

    def call(full_filename, upload_source, content_type:, mime_type: nil)
      names = full_filename.split('/')
      filename = names.pop
      parent_id = find_folder(names)

      meta = {name: filename, parents: [parent_id]}
      meta[:mime_type] = mime_type if mime_type

      file = service.create_file(
        meta,
        upload_source: upload_source,
        content_type: content_type,
        options: OPTIONS
      )

      {id: file.id, parent_id: parent_id}
    end

    private

    def find_folder(names)
      id = @base_folder_id

      names.each { |folder_name| id = find_or_create_folder(folder_name, id) }

      id
    end

    def find_or_create_folder(name, parent_id = nil)
      folder_id = parent_id || @base_folder_id

      res = service.list_files(
        q: "mimeType='#{FOLDER_MIME_TYPE}' and name='#{name}' and '#{folder_id}' in parents and not trashed"
      )

      return res.files.first.id if res.files.any?

      service.create_file(
        {name: name, mime_type: FOLDER_MIME_TYPE, parents: [folder_id]},
        options: OPTIONS
      ).id
    end
  end
end
