class PostReadOnly < Post
  establish_connection "ro_#{Rails.env}".to_sym
  attr_readonly *column_names
end
