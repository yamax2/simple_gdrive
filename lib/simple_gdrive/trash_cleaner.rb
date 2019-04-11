module SimpleGdrive
  # cleans then user's trash bin
  class TrashCleaner < Base
    def call
      service.empty_file_trash
    end
  end
end
