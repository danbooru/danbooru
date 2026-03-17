require "test_helper"

module Source::Tests::URL
  class DeviantArtUrlTest < ActiveSupport::TestCase
    context "DeviantArt URLs" do
      should be_image_url(
        "http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg",
        "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
        "http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png",
        "http://fc00.deviantart.net/fs71/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg",
        "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc",
        "https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/e1d5122b-6fee-44df-8b8f-e6e8daa3396d/dbn3ef5-9e051a71-251d-4e0f-b5f1-3beb5e6a8667.swf?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTcwOTQ2NTcwNywiaWF0IjoxNzA5NDY1MDk3LCJqdGkiOiI2NWU0NWUxMzAxNTk2Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvZTFkNTEyMmItNmZlZS00NGRmLThiOGYtZTZlOGRhYTMzOTZkXC9kYm4zZWY1LTllMDUxYTcxLTI1MWQtNGUwZi1iNWYxLTNiZWI1ZTZhODY2Ny5zd2YifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.6ZShJVsXxVs73R2Akw_9t-BMJKjqPUbNKHkIbzMsqeU",
        "http://www.deviantart.com/download/135944599/Touhou___Suwako_Moriya_Colored_by_Turtle_Chibi.png",
        "http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg",
        "http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg",
      )

      should be_page_url(
        "https://fav.me/dbc3a48",
        "https://www.deviantart.com/view/685436408",
        "https://www.deviantart.com/view.php?id=685436408",
        "https://www.deviantart.com/view-full.php?id=685436408",
        "https://www.deviantart.com/noizave/art/685436408",
        "https://sta.sh/0wxs31o7nn2",
      )

      should be_profile_url(
        "https://www.deviantart.com/noizave",
        "https://noizave.deviantart.com",
        "https://noizave.daportfolio.com",
        "https://noizave.artworkfolio.com",
      )

      should_not be_profile_url(
        "https://deviantart.net",
        "https://www.deviantart.com",
      )

      should be_bad_source(
        "https://www.deviantart.com/users/outgoing?https://www.google.com",
      )

      should parse_url("http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg").into(
        page_url: "https://www.deviantart.com/mar11co/art/You-Are-Already-Dead-408921710",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg").into(
        page_url: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896",
      )

      should parse_url("http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png").into(
        page_url: "https://www.deviantart.com/melisaongmiqin/art/Illustration-Tokyo-Encount-Oei-659256076",
      )

      should parse_url("http://fc00.deviantart.net/fs71/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg").into(
        page_url: "https://www.deviantart.com/deviation/417560500",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc").into(
        page_url: "https://www.deviantart.com/deviation/599977532",
      )

      should parse_url("https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/e1d5122b-6fee-44df-8b8f-e6e8daa3396d/dbn3ef5-9e051a71-251d-4e0f-b5f1-3beb5e6a8667.swf?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTcwOTQ2NTcwNywiaWF0IjoxNzA5NDY1MDk3LCJqdGkiOiI2NWU0NWUxMzAxNTk2Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvZTFkNTEyMmItNmZlZS00NGRmLThiOGYtZTZlOGRhYTMzOTZkXC9kYm4zZWY1LTllMDUxYTcxLTI1MWQtNGUwZi1iNWYxLTNiZWI1ZTZhODY2Ny5zd2YifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.6ZShJVsXxVs73R2Akw_9t-BMJKjqPUbNKHkIbzMsqeU").into(
        page_url: "https://www.deviantart.com/deviation/703917761",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/b1f96af6-56a3-47a8-b7f4-406f243af3a3/daihpha-9f1fcd2e-7557-4db5-951b-9aedca9a3ae7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2IxZjk2YWY2LTU2YTMtNDdhOC1iN2Y0LTQwNmYyNDNhZjNhM1wvZGFpaHBoYS05ZjFmY2QyZS03NTU3LTRkYjUtOTUxYi05YWVkY2E5YTNhZTcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.YWZwVhPQHRLzRZUU2cTDXuWuA6ExFH57oFfGzAkxO6Y&filename=legend_of_galactic_heroes_by_hideyoshi_daihpha.jpg").into(
        page_url: "https://www.deviantart.com/hideyoshi/art/Legend-Of-Galactic-Heroes-635721022",
      )

      should parse_url("https://api-da.wixmp.com/_api/download/file?downloadToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTU5MDkwMTUzMywiaWF0IjoxNTkwOTAwOTIzLCJqdGkiOiI1ZWQzMzhjNWQ5YjI0Iiwib2JqIjpudWxsLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdLCJwYXlsb2FkIjp7InBhdGgiOiJcL2ZcL2U0NmE0OGViLTNkMGItNDQ5ZS05MGRjLTBhMWIzMWNiMTM2MVwvZGQzcDF4OS1mYjQ3YmM4Zi02NTNlLTQyYTItYmI0ZC1hZmFmOWZjMmI3ODEuanBnIn19.-zo8E2eDmkmDNCK-sMabBajkaGtVYJ2Q20iVrUtt05Q").into(
        work_id: 792_268_029,
        jwt_path: "/f/e46a48eb-3d0b-449e-90dc-0a1b31cb1361/dd3p1x9-fb47bc8f-653e-42a2-bb4d-afaf9fc2b781.jpg",
        max_width: nil,
        max_height: nil,
        page_url: "https://www.deviantart.com/deviation/792268029",
      )

      should parse_url("https://noizave.deviantart.com/art/test-post-please-ignore-685436408").into(
        username: "noizave",
        title: "test-post-please-ignore",
        work_id: 685_436_408,
        page_url: "https://www.deviantart.com/noizave/art/Test-Post-Please-Ignore-685436408",
        profile_url: "https://www.deviantart.com/noizave",
      )

      should parse_url("https://sta.sh/zip/21leo8mz87ue").into(
        stash_id: "21leo8mz87ue",
        page_url: "https://sta.sh/21leo8mz87ue",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/d8995973-0b32-4a7d-8cd8-d847d083689a/d797tit-1eac22e0-38b6-4eae-adcb-1b72843fd62a.png/v1/fill/w_720,h_1110,q_75,strp/goruto_by_xyelkiltrox-d797tit.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9kODk5NTk3My0wYjMyLTRhN2QtOGNkOC1kODQ3ZDA4MzY4OWEvZDc5N3RpdC0xZWFjMjJlMC0zOGI2LTRlYWUtYWRjYi0xYjcyODQzZmQ2MmEucG5nIiwid2lkdGgiOiI8PTcyMCIsImhlaWdodCI6Ijw9MTExMCJ9XV19.vSlSlntfQQ9qwJBv8mldhKRtllVAhUESfQfo6P0lHsU").into(
        work_id: 438_744_629,
        max_width: 720,
        max_height: 1110,
        full_image_url: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/d8995973-0b32-4a7d-8cd8-d847d083689a/d797tit-1eac22e0-38b6-4eae-adcb-1b72843fd62a.png",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130,q_80,strp/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw").into(
        work_id: 808_603_826,
        max_width: 800,
        max_height: 1130,
        full_image_url: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_75,strp/test.gif?token=bad").into(
        full_image_url: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017/test.gif?token=bad",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/9db3eda4-8fde-4d93-b89b-e3ae7a54d795/djzvr1g-78e3c8b6-7ee2-4d3c-88ca-6843749dfacc.jpg/v1/fill/w_1280,h_1600,blur_30/ophelia_and_hannah___commission_by_snack20_djzvr1g-fullview.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvYmoiOltbeyJwYXRoIjoiL2YvOWRiM2VkYTQtOGZkZS00ZDkzLWI4OWItZTNhZTdhNTRkNzk1L2RqenZyMWctNzhlM2M4YjYtN2VlMi00ZDNjLTg4Y2EtNjg0Mzc0OWRmYWNjLmpwZyIsIndpZHRoIjoiPD0xMjgwIiwiaGVpZ2h0IjoiPD0xNjAwIiwiYmx1ciI6IjMwIn1dXX0=.sig").into(
        full_image_url: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/9db3eda4-8fde-4d93-b89b-e3ae7a54d795/djzvr1g-78e3c8b6-7ee2-4d3c-88ca-6843749dfacc.jpg/v1/fill/w_1280,h_1600,blur_30/ophelia_and_hannah___commission_by_snack20_djzvr1g-fullview.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvYmoiOltbeyJwYXRoIjoiL2YvOWRiM2VkYTQtOGZkZS00ZDkzLWI4OWItZTNhZTdhNTRkNzk1L2RqenZyMWctNzhlM2M4YjYtN2VlMi00ZDNjLTg4Y2EtNjg0Mzc0OWRmYWNjLmpwZyIsIndpZHRoIjoiPD0xMjgwIiwiaGVpZ2h0IjoiPD0xNjAwIiwiYmx1ciI6IjMwIn1dXX0=.sig",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/9db3eda4-8fde-4d93-b89b-e3ae7a54d795/djzvr1g-78e3c8b6-7ee2-4d3c-88ca-6843749dfacc.jpg/v1/fill/w_1280,h_1600,blur_30/ophelia_and_hannah___commission_by_snack20_djzvr1g-fullview.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvYmoiOltbeyJwYXRoIjoiL2YvOWRiM2VkYTQtOGZkZS00ZDkzLWI4OWItZTNhZTdhNTRkNzk1L2RqenZyMWctNzhlM2M4YjYtN2VlMi00ZDNjLTg4Y2EtNjg0Mzc0OWRmYWNjLmpwZyIsIndpZHRoIjoiPD0xMjgwIiwiaGVpZ2h0IjoiPD0xNjAwIn1dXX0=.sig").into(
        full_image_url: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/9db3eda4-8fde-4d93-b89b-e3ae7a54d795/djzvr1g-78e3c8b6-7ee2-4d3c-88ca-6843749dfacc.jpg/v1/fill/w_1280,h_1600/ophelia_and_hannah___commission_by_snack20_djzvr1g-fullview.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvYmoiOltbeyJwYXRoIjoiL2YvOWRiM2VkYTQtOGZkZS00ZDkzLWI4OWItZTNhZTdhNTRkNzk1L2RqenZyMWctNzhlM2M4YjYtN2VlMi00ZDNjLTg4Y2EtNjg0Mzc0OWRmYWNjLmpwZyIsIndpZHRoIjoiPD0xMjgwIiwiaGVpZ2h0IjoiPD0xNjAwIn1dXX0=.sig",
      )

      should parse_url("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc").into(
        full_image_url: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc",
      )

      should parse_url("https://fav.me/dbc3a48").into(page_url: "https://www.deviantart.com/deviation/685436408")
      should parse_url("https://www.deviantart.com/view/685436408").into(page_url: "https://www.deviantart.com/deviation/685436408")
      should parse_url("https://www.deviantart.com/view.php?id=685436408").into(page_url: "https://www.deviantart.com/deviation/685436408")
      should parse_url("https://www.deviantart.com/view-full.php?id=685436408").into(page_url: "https://www.deviantart.com/deviation/685436408")
      should parse_url("https://www.deviantart.com/noizave/art/685436408").into(page_url: "https://www.deviantart.com/deviation/685436408")
      should parse_url("https://www.deviantart.com/stash/0wxs31o7nn2").into(page_url: "https://sta.sh/0wxs31o7nn2")
      should parse_url("https://noizave.daportfolio.com").into(profile_url: "https://www.deviantart.com/noizave")
      should parse_url("https://noizave.artworkfolio.com").into(profile_url: "https://www.deviantart.com/noizave")

      should "return the existing page url from page_url_from_redirect" do
        assert_equal("https://www.deviantart.com/deviation/685436408", Source::URL.parse("https://www.deviantart.com/view/685436408").page_url_from_redirect(mock))
      end

      should "resolve the page url from a redirect for old image urls" do
        url = Source::URL.parse("http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg")
        redirect_url = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/d8995973-0b32-4a7d-8cd8-d847d083689a/d797tit-1eac22e0-38b6-4eae-adcb-1b72843fd62a.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9kODk5NTk3My0wYjMyLTRhN2QtOGNkOC1kODQ3ZDA4MzY4OWEvZDc5N3RpdC0xZWFjMjJlMC0zOGI2LTRlYWUtYWRjYi0xYjcyODQzZmQ2MmEucG5nIiwid2lkdGgiOiI8PTcyMCIsImhlaWdodCI6Ijw9MTExMCJ9XV19.vSlSlntfQQ9qwJBv8mldhKRtllVAhUESfQfo6P0lHsU"

        http = mock
        http.stubs(:redirect_url).returns(redirect_url)
        http.stubs(:cache).returns(http)

        assert_equal("https://www.deviantart.com/deviation/438744629", url.page_url_from_redirect(http))
      end
    end

    should parse_url("http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg").into(site_name: "Deviant Art")
  end
end
