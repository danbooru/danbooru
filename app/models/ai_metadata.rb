# frozen_string_literal: true

class AIMetadata < ApplicationRecord
  self.table_name = "ai_metadata"
  self.ignored_columns = [:sampler, :seed, :steps, :cfg_scale, :model_hash]

  PARAMETER_ORDER = ["Sampler", "Seed", "Steps", "Cfg Scale", "Model Hash", "Width", "Height"]
  PARAMETER_REGEX = /\s*([\w ]+):\s*("(?:\\|\"|[^\"])+"|[^,]*)(?:,|$)/

  include Versionable
  attr_accessor :updater

  before_save :normalize_prompts
  before_save :normalize_parameters
  before_validation :normalize_model_hash
  validate :validate_model_hash, if: :model_hash_changed?
  validates :post_id, uniqueness: true
  belongs_to :post

  # XXX post_id shouldn't be versionable but it needs to be set in new versions due to foreign key.
  versionable :prompt, :negative_prompt, :parameters, :post_id

  scope :nonblank, -> {
    where("prompt != '' or negative_prompt != '' or parameters != '{}'")
  }

  concerning :SearchMethods do
    class_methods do
      def search(params, current_user)
        q = search_attributes(params, [:id, :post, :prompt, :negative_prompt, :parameters, :created_at, :updated_at], current_user: current_user)

        q = q.parameter_matches(params[:parameter_name], params[:parameter_value])

        q.apply_default_order(params)
      end

      def parameter_matches(name, value)
        if name.present?
          if value&.downcase == "none"
            where_json_has_key(:parameters, name).invert_where
          elsif value.present?
            where_json_contains(:parameters, { name.strip => value.strip }, cast: false)
          else
            where_json_has_key(:parameters, name.strip)
          end
        else
          all
        end
      end

      def all_labels
        select(Arel.sql("distinct jsonb_object_keys(parameters) as label")).order(:label)
      end

      def labels_like(string)
        all_labels.select { |ss| ss.label.ilike?(string) }.map(&:label)
      end
    end
  end

  def any_field_present?
    prompt.present? || negative_prompt.present? || parameters.present?
  end

  def self.new_from_metadata(metadata)
    subject = new(updater: CurrentUser.user)

    if metadata.has_key?("PNG:Comment")
      begin
        params = JSON.parse(metadata["PNG:Comment"])
        subject.prompt = params.delete("prompt") || metadata["PNG:Description"]
        subject.negative_prompt = params.delete("uc")
        subject.parameters = params.filter_map do |key, value|
          [key.gsub("_", " ").titleize, value] if key.present? && value.present?
        end.to_h
      rescue JSON::ParserError
      end
    elsif metadata.has_key?("PNG:Parameters") || metadata.has_key?("ExifIFD:UserComment")
      prompt, negative_prompt, params = parse_parameters(metadata["PNG:Parameters"] || metadata["ExifIFD:UserComment"])
      subject.prompt = prompt
      subject.negative_prompt = negative_prompt&.delete_prefix("Negative prompt: ")
      if params.present?
        params = params.scan(PARAMETER_REGEX).map { |field| [field[0].downcase, field[1].tr('"', "")] }.to_h unless params.is_a?(Hash)
        subject.parameters = params.filter_map do |key, value|
          [key.gsub("_", " ").titleize, value] if key.present? && value.present?
        end.to_h
      end
    end

    if model_hash = metadata["PNG:Source"].to_s.scan(/[A-Fa-f0-9]{8}/).last&.downcase
      subject.parameters["Model Hash"] ||= model_hash
    end

    subject
  end

  def self.parse_parameters(params)
    return ["", "", ""] if params.blank?

    if params.include?("sui_image_params")
      params = JSON.parse(params)["sui_image_params"]
      prompt = params["prompt"]
      negative_prompt = params["negativeprompt"]
      parameters = params.without("prompt", "negativeprompt")
      return [prompt, negative_prompt, parameters]
    end

    params, _, last_line = params.rpartition("\n")
    if !last_line.match?(PARAMETER_REGEX)
      params << "\n" << last_line
      last_line = ""
    end

    data = params.split(/\s*Negative prompt:\s*/)
    if data.one?
      [*data, nil, last_line]
    elsif data.length > 2
      [data[..-2].join("Negative prompt: "), data[-1], last_line]
    else
      [*data, last_line]
    end
  end

  def sorted_parameters
    parameters.sort do |first, second|
      [PARAMETER_ORDER.index(first[0]) || PARAMETER_ORDER.length + 1, first[0]] <=> [PARAMETER_ORDER.index(second[0]) || PARAMETER_ORDER.length + 1, second[0]]
    end
  end

  def normalize_prompts
    self.prompt = prompt&.split(/\s*,\s*/)&.join(", ")
    self.negative_prompt = negative_prompt&.split(/\s*,\s*/)&.join(", ")
  end

  def normalize_parameters
    self.parameters = self.parameters.filter_map do |key, value|
      [key.gsub("_", " ").strip.titleize, value.strip] if key.present? && value.present?
    end.to_h
  end

  def model_hash_changed?
    self.parameters["Model Hash"].present? && self.parameters["Model Hash"] != parameters_was["Model Hash"]
  end

  def normalize_model_hash
    if self.parameters["Model Hash"].present?
      self.parameters["Model Hash"] = self.parameters["Model Hash"].downcase
    end
  end

  def validate_model_hash
    if self.parameters["Model Hash"].present? && !self.parameters["Model Hash"].match?(/\A[a-f0-9]+\Z/)
      errors.add(:model_hash, "is invalid")
    end
  end

  def revert_to(version)
    if post_id != version.post_id
      raise RevertError, "You cannot revert to a previous metadata version of another post."
    end

    self.prompt = version.prompt
    self.negative_prompt = version.negative_prompt
    self.parameters = version.parameters

    self.updater = CurrentUser.user
  end

  def revert_to!(version)
    revert_to(version)
    save!
  end

  def self.available_includes
    %i[post]
  end
end
