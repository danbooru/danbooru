# frozen_string_literal: true

# A custom validator for ensuring uploaded files have filenames that are valid UTF-8 and don't contain NUL bytes.
#
# @example validates :files, uploaded_filename: true
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class UploadedFilenameValidator < ActiveModel::EachValidator
  def validate_each(record, _attr, value)
    files = value.respond_to?(:each_value) ? value.each_value : Array.wrap(value)

    files.each do |file|
      filename = String.new(file.original_filename.to_s, encoding: Encoding::UTF_8)

      if !filename.valid_encoding?
        record.errors.add(:base, "'#{filename.scrub}' isn't a valid filename (filenames must be UTF-8)")
      elsif filename.include?("\0")
        record.errors.add(:base, "'#{filename.tr("\0", "�")}' isn't a valid filename (filenames can't contain NUL bytes)")
      end
    end
  end
end
