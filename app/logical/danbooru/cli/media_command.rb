# frozen_string_literal: true

# `bin/booructl media` commands for regenerating media assets.
class Danbooru::CLI::MediaCommand < Danbooru::CLI::Command
  namespace "media"

  desc "regenerate [SEARCH]", "Regenerate thumbnails, samples, metadata, and AI tags for media assets"
  long_desc <<~EOS
    Regenerate thumbnails, samples, metadata, and AI tags for all media assets matching the search, or for all media
    assets if no search is given. The search uses the same syntax as the /media_assets search, for example
    "id:1..1000 filetype:png" or "date:>2024-01-01".

    Example: bin/booructl media regenerate "filetype:mp4" --no-ai-tags
  EOS
  option :metadata, type: :boolean, default: true, desc: "Regenerate the dimensions, file size, and EXIF metadata"
  option :files, type: :boolean, default: true, desc: "Regenerate thumbnails and samples"
  option :ai_tags, type: :boolean, default: true, desc: "Regenerate AI tags"
  option :dry_run, type: :boolean, default: false, desc: "List the media assets to regenerate without regenerating them"
  def regenerate(search = "")
    media_assets = MediaAssetQuery.search(search, current_user: User.system, relation: MediaAsset.active)

    process_each(media_assets, "media asset") do |media_asset|
      media_asset.regenerate!(metadata: options[:metadata], files: options[:files], ai_tags: options[:ai_tags])
    end
  end
end
