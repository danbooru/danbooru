#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

require 'aws/s3'

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

files = "424276a46717a932bb9195e65d47dca4.gif
c91c68579d8698a0e090f61bd69af67c.jpg
108a1bea9259e660ce7ec710132192bd.gif
773213a4e08132a148a4b270d88001ec.jpg
2bd8f23f43fe8bde50f37e9533cc2f01.jpg
363afa3e90708daa6f5fc09df83eb446.gif
2afe888d6d4fb04ccc8b5e31fe247f28.gif
938785a540cab00918231949d2bd2c2d.jpg
9fce8a73db402e28a22dffba4072dd09.gif
53d1925948cdd054475556f60aac58c0.jpg
6be989aa5854ddd211060252aebc7435.jpg
35371159177fec6e1cfe33ce1e8cb2a4.jpg
88bfad0ed5b5f4b7a14b63ed3e4160ae.jpg
7bdad95ccd4eca1e5c1899a5b3fd9757.jpg
26df2ed194a57aff03e5199cf5bcbe1a.jpg
3fbb9be8c14fb6ce51b86ead55666b63.jpg
dd9ca526c947812eb7b5cb8638858090.jpg
bde86123407c1e9f84000bc5261c6821.gif
dca035595a4c87a9074b5c0eb20c1b62.gif
587c4214a75aa1d2762486d119582ca5.gif
39e088fe7bca020d844316fcf71a5bf2.jpg
cd5a9e4d98ee4f5e3532ff6bab635890.jpg
f100e8add26908f1374d706f53d99cfb.gif
8891e230b920c26bb2a05a47fb75961f.jpg
c82a7d3caf2915251a6ab2cb3f66a4b9.jpg
c3443778b89ffe0914e7ea4d6004b35f.rar
135c5b7e158d11f109fda7f0039afb68.jpg
5e153c126bb41d90ab488a09e3bc1271.jpg
c655efc1b4292f17db74bb07fef63e9e.jpg
66fffc6df639c9bf7ce9a9f9e3a18b7a.jpg
64d06a341120102b7b48ff3e8f437538.gif
634abd39db90f5fa5d7c5a7a2d427131.gif".scan(/\S+/)

AWS::S3::Base.establish_connection!(
  :access_key_id => File.read(File.expand_path("~/.s3/access_key")),
  :secret_access_key => File.read(File.expand_path("~/.s3/secret_access_key"))
)

files.each do |file_name|
  bad_md5 = file_name.split(/\./).first
  correct_md5 = Digest::MD5.hexdigest(AWS::S3::S3Object.value(file_name, "danbooru"))
  puts "update posts set md5 = '#{correct_md5}' where md5 = '#{bad_md5}';"
  # Post.find_by_md5(bad_md5).update_column(:md5, correct_md5)
end
