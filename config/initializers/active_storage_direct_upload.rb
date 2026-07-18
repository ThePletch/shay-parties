# Direct uploads already declare content_type, byte_size, and checksum when the blob
# record is created. Attaching that blob still runs identify_without_saving, which
# downloads the first 4KB from S3 synchronously during the request.
ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::Blob.prepend(Module.new do
    def identify_without_saving
      if direct_upload_blob?
        self.identified = true
        return
      end

      super
    end

    private

      def direct_upload_blob?
        !identified? && content_type.present? && byte_size.to_i.positive? && checksum.present?
      end
  end)
end
