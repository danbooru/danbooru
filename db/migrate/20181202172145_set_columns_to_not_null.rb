class SetColumnsToNotNull < ActiveRecord::Migration[5.2]
  def change
    Artist.without_timeout do
      change_column_null :artist_versions, :urls, false, '{}'
      change_column_null :artist_versions, :other_names, false, '{}'
      change_column_null :artist_versions, :group_name, false, ''
      change_column_default :artist_versions, :group_name, from: nil, to: ""

      change_column_null :artists, :other_names, false, '{}'
      change_column_null :artists, :group_name, false, ''
      change_column_default :artists, :group_name, from: nil, to: ""

      change_column_null :wiki_pages, :other_names, false, '{}'
      change_column_null :wiki_page_versions, :other_names, false, '{}'
    end
  end
end
