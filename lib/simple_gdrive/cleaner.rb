module SimpleGdrive
  # Cleans the directory
  # Returns array of removed file names
  class Cleaner < Base
    def call
      @page_token = nil
      @files_to_remove = {}

      begin
        fetch_batch
      end until @page_token.nil?

      remove_files

      @files_to_remove.values
    end

    private

    def fetch_batch
      response = service.list_files(
        q: "'#{@base_folder_id}' in parents and not trashed",
        fields: 'nextPageToken, files(id, name, parents)',
        page_token: @page_token
      )

      @page_token = response.next_page_token

      response.files.each_with_object(@files_to_remove) { |file, memo| memo[file.id] = file.name }
    end

    def remove_files
      @files_to_remove.keys.each { |id| service.delete_file(id) }
    end
  end
end
