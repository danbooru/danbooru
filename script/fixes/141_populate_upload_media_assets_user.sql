UPDATE upload_media_assets
SET user_id = uploads.uploader_id
FROM uploads
WHERE uploads.id = upload_media_assets.upload_id AND upload_media_assets.user_id IS NULL;
