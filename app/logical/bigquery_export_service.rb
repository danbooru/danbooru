# frozen_string_literal: true

# Perform a daily database dump to BigQuery and to Google Cloud Storage. This
# contains all data visible to anonymous users.
#
# The database dumps are publicly accessible. The BigQuery data is at
# `danbooru1.danbooru_public.{table}`. The Google Cloud Storage data is at
# `gs://danbooru_public/data/{table}.json`. The storage bucket contains the data
# in newline-delimited JSON format.
#
# @see DanbooruMaintenance#daily
# @see https://console.cloud.google.com/storage/browser/danbooru_public
# @see https://console.cloud.google.com/bigquery?d=danbooru_public&p=danbooru1&t=posts&page=table
# @see https://cloud.google.com/bigquery/docs
# @see https://cloud.google.com/storage/docs
# @see https://en.wikipedia.org/wiki/JSON_streaming#Line-delimited_JSON
class BigqueryExportService
  extend Memoist

  attr_reader :model, :dataset_name, :credentials

  # Prepare to dump a table. Call {#export!} to dump it.
  # @param model [ApplicationRecord] the database table to dump
  # @param dataset_name [String] the BigQuery dataset name
  # @param credentials [String] the Google Cloud credentials (in JSON format)
  def initialize(model = nil, dataset_name: "danbooru_public", credentials: default_credentials)
    @model = model
    @dataset_name = dataset_name
    @credentials = credentials
  end

  # Start a background job for each table to export it to BigQuery.
  def self.async_export_all!(**options)
    models.each do |model|
      BigqueryExportJob.perform_later(model: model, **options)
    end
  end

  # The list of database tables to dump.
  def self.models
    Rails.application.eager_load!

    models = ApplicationRecord.descendants.sort_by(&:name)

    models -= [
      GoodJob::BaseRecord,
      GoodJob::Process,
      GoodJob::Execution,
      GoodJob::DiscreteExecution,
      GoodJob::BatchRecord,
      GoodJob::Job,
      GoodJob::Setting,
      TagRelationship,
      ArtistVersion,
      ArtistCommentaryVersion,
      NoteVersion,
      PoolVersion,
      PostVersion,
      WikiPageVersion,
      Post,
      PostEvent,
      PostVote,
      MediaAsset,
      Favorite,
      AITag,
      UserAction
    ]

    models
  end

  def enabled?
    credentials.present?
  end

  # Dump the table to Cloud Storage and BigQuery.
  def export!
    return unless enabled? && records.any?

    file = dump_records!
    upload_to_bigquery!(file)
  ensure
    file&.close
  end

  # Dump the table's records to a gzipped, newline-delimited JSON tempfile.
  def dump_records!(file = Danbooru::Tempfile.new("danbooru-export-dump-#{model.name}-", binmode: true))
    gzip = Zlib::GzipWriter.new(file)

    CurrentUser.scoped(User.anonymous) do
      records.find_each(batch_size: 5_000) do |record|
        gzip.puts(record.to_json)
      end
    end

    gzip.finish
    file.fsync
    file
  end

  # Upload the JSON dump to Cloud Storage, then load it into BigQuery.
  def upload_to_bigquery!(file)
    table_name = model.model_name.collection
    gsfilename = "data/#{table_name}.json"

    gsfile = bucket.create_file(file.path, gsfilename, content_encoding: "gzip")
    job = dataset.load_job(table_name, gsfile, format: "json", autodetect: true, create: "needed", write: "truncate")

    job.wait_until_done!
    job
  end

  # The list of records to dump.
  def records
    model.visible(User.anonymous)
  end

  # Find or create the BigQuery dataset.
  def dataset
    bigquery.dataset(dataset_name) || bigquery.create_dataset(dataset_name)
  end

  # Find or create the Google Storage bucket.
  def bucket
    storage.bucket(dataset_name, user_project: true) || storage.create_bucket(dataset_name, acl: "public", default_acl: "public", storage_class: "standard", location: "us-east1", requester_pays: true, user_project: true)
  end

  # The BigQuery API client.
  def bigquery
    Google::Cloud::Bigquery.new(credentials: credentials)
  end

  # The Cloud Storage API client.
  def storage
    Google::Cloud::Storage.new(credentials: credentials)
  end

  def default_credentials
    return nil unless Danbooru.config.google_cloud_credentials.present?
    JSON.parse(Danbooru.config.google_cloud_credentials)
  end

  memoize :dataset, :bucket, :bigquery, :storage, :default_credentials
end
