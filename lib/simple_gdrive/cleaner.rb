module SimpleGdrive
  # Cleans the directory
  # Returns array of removed file names
  class Cleaner < Base
    def initialize(base_folder_id:, move_to_trash: false)
      @base_folder_id = base_folder_id
      @move_to_trash = move_to_trash
    end

    def call
      @page_token = nil
      @files_to_remove = {}

      loop do
        fetch_batch
        break if @page_token.nil?
      end

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
      @files_to_remove.keys.each do |id|
        if @move_to_trash
          service.update_file(id, {trashed: true}, {})
        else
          service.delete_file(id)
        end
      end
    end
  end
end
