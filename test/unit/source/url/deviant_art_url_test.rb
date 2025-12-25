require "test_helper"

module Source::Tests::URL
  class DeviantArtUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg",
          "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
          "http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png",
          "http://fc00.deviantart.net/fs71/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg",
          "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc",
          "https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/e1d5122b-6fee-44df-8b8f-e6e8daa3396d/dbn3ef5-9e051a71-251d-4e0f-b5f1-3beb5e6a8667.swf?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTcwOTQ2NTcwNywiaWF0IjoxNzA5NDY1MDk3LCJqdGkiOiI2NWU0NWUxMzAxNTk2Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvZTFkNTEyMmItNmZlZS00NGRmLThiOGYtZTZlOGRhYTMzOTZkXC9kYm4zZWY1LTllMDUxYTcxLTI1MWQtNGUwZi1iNWYxLTNiZWI1ZTZhODY2Ny5zd2YifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.6ZShJVsXxVs73R2Akw_9t-BMJKjqPUbNKHkIbzMsqeU",
          "http://www.deviantart.com/download/135944599/Touhou___Suwako_Moriya_Colored_by_Turtle_Chibi.png",
          "http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg",
          "http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg",
        ],
        page_urls: [
          "https://fav.me/dbc3a48",
          "https://www.deviantart.com/view/685436408",
          "https://www.deviantart.com/view.php?id=685436408",
          "https://www.deviantart.com/view-full.php?id=685436408",
          "https://www.deviantart.com/noizave/art/685436408",
          "https://sta.sh/0wxs31o7nn2",
        ],
        profile_urls: [
          "https://www.deviantart.com/noizave",
          "https://noizave.deviantart.com",
          "https://noizave.daportfolio.com",
          "https://noizave.artworkfolio.com",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://deviantart.net",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg",
                             page_url: "https://www.deviantart.com/mar11co/art/You-Are-Already-Dead-408921710",)
      url_parser_should_work("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
                             page_url: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896",)
      url_parser_should_work("http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png",
                             page_url: "https://www.deviantart.com/melisaongmiqin/art/Illustration-Tokyo-Encount-Oei-659256076",)
      url_parser_should_work("http://fc00.deviantart.net/fs71/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg",
                             page_url: "https://www.deviantart.com/deviation/417560500",)
      url_parser_should_work("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc",
                             page_url: "https://www.deviantart.com/deviation/599977532",)
      url_parser_should_work("https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/e1d5122b-6fee-44df-8b8f-e6e8daa3396d/dbn3ef5-9e051a71-251d-4e0f-b5f1-3beb5e6a8667.swf?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTcwOTQ2NTcwNywiaWF0IjoxNzA5NDY1MDk3LCJqdGkiOiI2NWU0NWUxMzAxNTk2Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvZTFkNTEyMmItNmZlZS00NGRmLThiOGYtZTZlOGRhYTMzOTZkXC9kYm4zZWY1LTllMDUxYTcxLTI1MWQtNGUwZi1iNWYxLTNiZWI1ZTZhODY2Ny5zd2YifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.6ZShJVsXxVs73R2Akw_9t-BMJKjqPUbNKHkIbzMsqeU",
                             page_url: "https://www.deviantart.com/deviation/703917761",)
      url_parser_should_work("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/b1f96af6-56a3-47a8-b7f4-406f243af3a3/daihpha-9f1fcd2e-7557-4db5-951b-9aedca9a3ae7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2IxZjk2YWY2LTU2YTMtNDdhOC1iN2Y0LTQwNmYyNDNhZjNhM1wvZGFpaHBoYS05ZjFmY2QyZS03NTU3LTRkYjUtOTUxYi05YWVkY2E5YTNhZTcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.YWZwVhPQHRLzRZUU2cTDXuWuA6ExFH57oFfGzAkxO6Y&filename=legend_of_galactic_heroes_by_hideyoshi_daihpha.jpg",
                             page_url: "https://www.deviantart.com/hideyoshi/art/Legend-Of-Galactic-Heroes-635721022",)

      url_parser_should_work("https://fav.me/dbc3a48", page_url: "https://www.deviantart.com/deviation/685436408")
      url_parser_should_work("https://www.deviantart.com/view/685436408", page_url: "https://www.deviantart.com/deviation/685436408")
      url_parser_should_work("https://www.deviantart.com/view.php?id=685436408", page_url: "https://www.deviantart.com/deviation/685436408")
      url_parser_should_work("https://www.deviantart.com/view-full.php?id=685436408", page_url: "https://www.deviantart.com/deviation/685436408")
      url_parser_should_work("https://www.deviantart.com/noizave/art/685436408", page_url: "https://www.deviantart.com/deviation/685436408")
      url_parser_should_work("https://www.deviantart.com/stash/0wxs31o7nn2", page_url: "https://sta.sh/0wxs31o7nn2")
      url_parser_should_work("https://noizave.daportfolio.com", profile_url: "https://www.deviantart.com/noizave")
      url_parser_should_work("https://noizave.artworkfolio.com", profile_url: "https://www.deviantart.com/noizave")
    end
  end
end
