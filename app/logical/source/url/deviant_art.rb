# frozen_string_literal: true

# Unhandled:
#
# http://th04.deviantart.net/fs70/300W/f/2009/364/4/d/Alphes_Mimic___Rika_by_Juriesute.png
# http://fc02.deviantart.net/fs48/f/2009/186/2/c/Animation_by_epe_tohri.swf
# http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg
#
# http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg
# http://img04.deviantart.net/720b/i/2003/37/9/6/princess_peach.jpg
#
# http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg
# http://other00.deviantart.net/8863/o/2009/197/3/7/37ac79eaeef9fb32e6ae998e9a77d8dd.jpg
# http://fc09.deviantart.net/fs22/o/2009/197/3/7/37ac79eaeef9fb32e6ae998e9a77d8dd.jpg
# http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg

module Source
  class URL::DeviantArt < Source::URL
    RESERVED_SUBDOMAINS = %w[www]

    attr_reader :username, :work_id, :stash_id, :title, :file

    def self.match?(url)
      url.domain.in?(%w[artworkfolio.com daportfolio.com deviantart.net deviantart.com fav.me sta.sh]) || url.host.in?(%w[images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com wixmp-ed30a86b8c4ca887773594c2.wixmp.com api-da.wixmp.com])
    end

    def parse
      case [domain, *path_segments]

      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/52c4a3ad-d416-42f0-90f6-570983e36797/dczr28f-bd255304-01bf-4765-8cd3-e53983d3f78a.jpg
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130,q_80,strp/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw
      in "wixmp.com", *rest
        parse_filename

      # http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png
      # http://pre15.deviantart.net/81de/th/pre/f/2015/063/5/f/inha_by_inhaestudios-d8kfzm5.jpg
      # http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png
      # http://fc00.deviantart.net/fs71/f/2013/234/d/8/d84e05f26f0695b1153e9dab3a962f16-d6j8jl9.jpg
      # http://th04.deviantart.net/fs71/PRE/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg
      in "deviantart.net", *rest
        parse_filename

      # http://www.deviantart.com/download/135944599/Touhou___Suwako_Moriya_Colored_by_Turtle_Chibi.png
      # https://www.deviantart.com/download/549677536/countdown_to_midnight_by_kawacy-d939hwg.jpg?token=92090cd3910d52089b566661e8c2f749755ed5f8&ts=1438535525
      in "deviantart.com", "download", work_id, file
        parse_filename
        @work_id = work_id.to_i

      # https://www.deviantart.com/deviation/685436408
      in "deviantart.com", "deviation", work_id
        @work_id = work_id.to_i

      # https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408
      in "deviantart.com", username, "art", /^([a-zA-Z0-9-]+)-(\d+)$/ => title
        @username = username
        @title = $1
        @work_id = $2.to_i

      # https://noizave.deviantart.com/art/test-post-please-ignore-685436408
      in "deviantart.com", "art", /^([a-z0-9_-]+)-(\d+)$/i => title unless subdomain.in?(RESERVED_SUBDOMAINS)
        @username = subdomain
        @title = $1
        @work_id = $2.to_i

      # https://www.deviantart.com/noizave
      # https://deviantart.com/noizave
      # https://www.deviantart.com/nlpsllp/gallery
      in "deviantart.com", username, *rest
        @username = username

      # https://noizave.deviantart.com
      # http://nemupanart.daportfolio.com
      # http://regi-chan.artworkfolio.com
      in ("deviantart.com" | "daportfolio.com" | "artworkfolio.com"), *rest unless subdomain.in?(RESERVED_SUBDOMAINS)
        @username = subdomain

      # https://fav.me/dbc3a48
      # https://www.fav.me/dbc3a48
      in "fav.me", base36_id
        @work_id = base36_id.delete_prefix("d").to_i(36)

      # https://sta.sh/21leo8mz87ue (folder)
      # https://sta.sh/2uk0v5wabdt (subfolder)
      # https://sta.sh/0wxs31o7nn2 (single image)
      # Ref: https://www.deviantartsupport.com/en/article/what-is-stash-3391708
      # Ref: https://www.deviantart.com/developers/http/v1/20160316/stash_item/4662dd8b10e336486ea9a0b14da62b74
      in "sta.sh", stash_id
        @stash_id = stash_id

      # https://sta.sh/zip/21leo8mz87ue
      in "sta.sh", "zip", stash_id
        @stash_id = stash_id

      else
        nil
      end
    end

    def parse_filename
      case filename

      # http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png
      # http://pre15.deviantart.net/81de/th/pre/f/2015/063/5/f/inha_by_inhaestudios-d8kfzm5.jpg
      # http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130,q_80,strp/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw
      # https://www.deviantart.com/download/549677536/countdown_to_midnight_by_kawacy-d939hwg.jpg?token=92090cd3910d52089b566661e8c2f749755ed5f8&ts=1438535525
      when /^(.+)_by_(.+)[_-]d([a-z0-9]+)(?:-\w+)?$/i
        @file = filename
        @title = $1
        @username = $2.dasherize
        @work_id = $3.to_i(36)

      # http://fc00.deviantart.net/fs71/f/2013/234/d/8/d84e05f26f0695b1153e9dab3a962f16-d6j8jl9.jpg
      # http://th04.deviantart.net/fs71/PRE/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg
      when /^[a-f0-9]{32}-d([a-z0-9]+)$/
        @file = filename
        @work_id = $1.to_i(36)

      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/52c4a3ad-d416-42f0-90f6-570983e36797/dczr28f-bd255304-01bf-4765-8cd3-e53983d3f78a.jpg
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc
      when /^d([a-z0-9]{6})-\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/
        @file = filename
        @work_id = $1.to_i(36)

      # http://www.deviantart.com/download/135944599/Touhou___Suwako_Moriya_Colored_by_Turtle_Chibi.png
      # http://th04.deviantart.net/fs70/300W/f/2009/364/4/d/Alphes_Mimic___Rika_by_Juriesute.png
      # http://fc02.deviantart.net/fs48/f/2009/186/2/c/Animation_by_epe_tohri.swf
      # http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg
      when /^(.+)_by_(.+)$/
        @file = filename
        @title = $1
        @username = $2.dasherize

      else
        @file = filename

      end
    end

    def image_url?
      file.present?
    end

    def page_url
      if stash_id.present?
        "https://sta.sh/#{stash_id}"
      elsif username.present? && pretty_title.present? && work_id.present?
        "https://www.deviantart.com/#{username}/art/#{pretty_title}-#{work_id}"
      elsif work_id.present?
        "https://www.deviantart.com/deviation/#{work_id}"
      else
        nil
      end
    end

    def profile_url
      "https://www.deviantart.com/#{username}" if username.present?
    end

    def pretty_title
      title.titleize.strip.squeeze(" ").tr(" ", "-") if title.present?
    end
  end
end
