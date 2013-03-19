class UploadedTagsImporter
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def import!
    row = connection.exec("SELECT uploaded_tags FROM users WHERE id = #{user.id}").first
    if row
      user.update_attribute(:favorite_tags, row["uploaded_tags"])
    end
    connection.close
  rescue Exception
  end

  def connection
    @connection ||= PGconn.connect(:dbname => "danbooru", :host => "dbserver", :user => "albert")
  end
end
