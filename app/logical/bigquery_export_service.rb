# Export all public data in a model to BigQuery and to Google Cloud Storage.

class BigqueryExportService
  extend Memoist

  attr_reader :model, :dataset_name, :credentials

  def initialize(model = nil, dataset_name: "danbooru_public", credentials: default_credentials)
    @model = model
    @dataset_name = dataset_name
    @credentials = credentials
  end

  def self.async_export_all!(**options)
    models.each do |model|
      BigqueryExportJob.perform_later(model: model, **options)
    end
  end

  def self.models
    Rails.application.eager_load!

    models = ApplicationRecord.descendants.sort_by(&:name)
    models -= [Favorite, IpAddress, TagRelationship, ArtistVersion, ArtistCommentaryVersion, NoteVersion, PoolVersion, PostVersion, WikiPageVersion]
    models
  end

  def enabled?
    credentials.present?
  end

  def export!
    return unless enabled? && records.any?

    file = dump_records!
    upload_to_bigquery!(file)
  end

  # Dump the model records to a gzipped, newline-delimited JSON tempfile.
  def dump_records!
    file = Tempfile.new("danbooru-export-dump-", binmode: true)
    file = Zlib::GzipWriter.new(file)

    CurrentUser.scoped(User.anonymous) do
      records.find_each(batch_size: 5_000) do |record|
        file.puts(record.to_json)
      end
    end

    file.close # flush zlib footer
    file
  end

  # GCS: gs://danbooru_public/data/{model}.json
  # BQ: danbooru1.danbooru_public.{model}
  def upload_to_bigquery!(file)
    table_name = model.model_name.collection
    gsfilename = "data/#{table_name}.json"

    gsfile = bucket.create_file(file.path, gsfilename, content_encoding: "gzip")
    job = dataset.load_job(table_name, gsfile, format: "json", autodetect: true, create: "needed", write: "truncate")

    job.wait_until_done!
    job
  end

  # private

  def records
    model.visible(User.anonymous)
  end

  def dataset
    bigquery.dataset(dataset_name) || bigquery.create_dataset(dataset_name)
  end

  def bucket
    storage.bucket(dataset_name) || storage.create_bucket(dataset_name, acl: "public", default_acl: "public", storage_class: "standard", location: "us-east1")
  end

  def bigquery
    Google::Cloud::Bigquery.new(credentials: credentials)
  end

  def storage
    Google::Cloud::Storage.new(credentials: credentials)
  end

  def default_credentials
    return nil unless Danbooru.config.google_cloud_credentials.present?
    JSON.parse(Danbooru.config.google_cloud_credentials)
  end

  memoize :dataset, :bucket, :bigquery, :storage, :default_credentials
end
