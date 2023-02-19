# frozen_string_literal: true

class AIMetadata < ApplicationRecord
  PARAMETER_REGEX = /\s*([\w ]+):\s*("(?:\\|\"|[^\"])+"|[^,]*)(?:,|$)/

  include Versionable
  attr_accessor :updater

  before_save :normalize_prompts
  before_validation :normalize_model_hash
  validate :validate_model_hash, if: :model_hash_changed?

  belongs_to :post

  versionable :prompt, :negative_prompt, :sampler, :seed, :steps, :cfg_scale, :model_hash, :post_id

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :post_id, :prompt, :negative_prompt, :sampler, :seed, :steps, :cfg_scale, :model_hash, :created_at, :updated_at], current_user: current_user)

    q.apply_default_order(params)
  end

  def any_field_present?
    prompt.present? || negative_prompt.present? || sampler.present? || seed.present? || steps.present? || cfg_scale.present? || model_hash.present?
  end

  def self.new_from_metadata(metadata)
    subject = new(updater: CurrentUser.user)

    if metadata.has_key?("PNG:Comment")
      begin
        params = JSON.parse(metadata["PNG:Comment"])
        subject.prompt = metadata["PNG:Description"]
        subject.negative_prompt = params["uc"]
        subject.sampler = params["sampler"]
        subject.seed = params["seed"]
        subject.steps = params["steps"]
        subject.cfg_scale = params["scale"]
        subject.model_hash = metadata["PNG:Source"]&.scan(/\b[A-Fa-f0-9]+$/)&.first&.downcase
      rescue JSON::ParserError
      end
    elsif metadata.has_key?("PNG:Parameters") || metadata.has_key?("ExifIFD:UserComment")
      prompt, negative_prompt, params = parse_parameters(metadata["PNG:Parameters"] || metadata["ExifIFD:UserComment"])
      subject.prompt = prompt
      subject.negative_prompt = negative_prompt&.delete_prefix("Negative prompt: ")
      if params.present?
        params = params.scan(PARAMETER_REGEX).map { |field| [field[0].downcase, field[1].tr('"', "")] }.to_h
        subject.sampler = params["sampler"]
        subject.seed = params["seed"]
        subject.steps = params["steps"]
        subject.cfg_scale = params["cfg scale"]
        subject.model_hash  = params["model hash"]
      end
    end

    subject
  end

  def self.parse_parameters(parameters)
    return ["", "", ""] if parameters.blank?

    parameters, _, last_line = parameters.rpartition("\n")
    if !last_line.match?(PARAMETER_REGEX)
      parameters << "\n" << last_line
      last_line = ""
    end

    data = parameters.split(/\s*Negative prompt:\s*/)
    if data.one?
      [*data, nil, last_line]
    elsif data.length > 2
      [data[..-2].join("Negative prompt: "), data[-1], last_line]
    else
      [*data, last_line]
    end
  end

  def normalize_prompts
    self.prompt = prompt&.split(/\s*,\s*/)&.join(", ")
    self.negative_prompt = negative_prompt&.split(/\s*,\s*/)&.join(", ")
  end

  def normalize_model_hash
    self.model_hash = self.model_hash.downcase
  end

  def validate_model_hash
    if model_hash.present? && !model_hash.match?(/\A[a-f0-9]+\Z/)
      errors.add(:model_hash, "is invalid")
    end
  end

  def revert_to(version)
    if post_id != version.post_id
      raise RevertError, "You cannot revert to a previous metadata version of another post."
    end

    self.prompt = version.prompt
    self.negative_prompt = version.negative_prompt
    self.sampler = version.sampler
    self.seed = version.seed
    self.steps = version.steps
    self.cfg_scale = version.cfg_scale
    self.model_hash = version.model_hash

    self.updater = CurrentUser.user
  end

  def revert_to!(version)
    revert_to(version)
    save!
  end
end
