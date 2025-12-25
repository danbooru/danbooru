require "test_helper"

module Source::Tests::URL
  class BloggerUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s1600/tali-litho.jpg",
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s0/",
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/",
          "https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF",
          "https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF=s0",
          "https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s1600/Blog%2BImage%2B3%2B%25281%2529.png",
          "https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s0/",
          "https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/",
          "http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/s400/Copy+of+milla-jovovich-2.jpg",
          "http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/d/",
          "http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0",
        ],
        page_urls: [
          "http://benbotport.blogspot.com/2011/06/mass-effect-2.html",
          "http://vincentmcart.blogspot.com.es/2016/05/poison-sting.html?zx=141d0a1a4c3e3ba",
        ],
        profile_urls: [
          "https://www.blogger.com/profile/05678559930985966952",
          "http://benbotport.blogspot.com",
          "http://vincentmcart.blogspot.com.es",
        ],
      )
    end
  end
end
