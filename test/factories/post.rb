Factory.define(:post) do |f|
  f.md5 {|x| Time.now.to_f.to_s}
  f.uploader {|x| x.association(:user)}
  f.uploader_ip_addr "127.0.0.1"
  f.tag_string "tag1 tag2"
  f.tag_count 2
  f.tag_count_general 2
  f.file_ext "jpg"
  f.image_width 100
  f.image_height 200
  f.file_size 2000
  f.rating "q"
end
