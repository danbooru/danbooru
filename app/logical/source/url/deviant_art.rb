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

    attr_reader :username, :work_id, :stash_id, :title, :file, :jwt

    def self.match?(url)
      url.domain.in?(%w[artworkfolio.com daportfolio.com deviantart.net deviantart.com fav.me sta.sh]) ||
        url.host.in?(%w[images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com wixmp-ed30a86b8c4ca887773594c2.wixmp.com api-da.wixmp.com img-deviantart.wixmp.com])
    end

    def parse
      case [subdomain, domain, *path_segments]

      # https://api-da.wixmp.com/_api/download/file?downloadToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTU5MDkwMTUzMywiaWF0IjoxNTkwOTAwOTIzLCJqdGkiOiI1ZWQzMzhjNWQ5YjI0Iiwib2JqIjpudWxsLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdLCJwYXlsb2FkIjp7InBhdGgiOiJcL2ZcL2U0NmE0OGViLTNkMGItNDQ5ZS05MGRjLTBhMWIzMWNiMTM2MVwvZGQzcDF4OS1mYjQ3YmM4Zi02NTNlLTQyYTItYmI0ZC1hZmFmOWZjMmI3ODEuanBnIn19.-zo8E2eDmkmDNCK-sMabBajkaGtVYJ2Q20iVrUtt05Q
      in "api-da", "wixmp.com", "_api", "download", "file" if params[:downloadToken].present?
        @jwt = parse_jwt(params[:downloadToken])
        @work_id = work_id_from_token

      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/52c4a3ad-d416-42f0-90f6-570983e36797/dczr28f-bd255304-01bf-4765-8cd3-e53983d3f78a.jpg
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130,q_80,strp/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_75,strp/cc9686111dcffffffb5fcfaf0cf069fb.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi84YjQ3MmQ3MC1hMGQ2LTQxYjUtOWE2Ni1jMzU2ODcwOTBhY2MvZDIzamJyNC04YTA2YWYwMi03MGNiLTQ2ZGEtOGE5Ni00MmE2YmE3M2NkYjQuanBnIiwid2lkdGgiOiI8PTc4NiIsImhlaWdodCI6Ijw9MTAxNyJ9XV19.EXlDqS_4kMSDO26RTsuqE-H_XI0xSiO3dnAQRV6puqw"
      # https://img-deviantart.wixmp.com/f/618b1383-fa36-43cf-a5ef-dbcc45695591/dgpak1x-43de07ea-842f-4feb-96eb-5fddb8f96c58.png/v1/fill/w_1280,h_1811/emomei_by_sayohyou_dgpak1x-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTgxMSIsInBhdGgiOiJcL2ZcLzYxOGIxMzgzLWZhMzYtNDNjZi1hNWVmLWRiY2M0NTY5NTU5MVwvZGdwYWsxeC00M2RlMDdlYS04NDJmLTRmZWItOTZlYi01ZmRkYjhmOTZjNTgucG5nIiwid2lkdGgiOiI8PTEyODAifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6aW1hZ2Uub3BlcmF0aW9ucyJdfQ.Vh93ks4buG6phMwmIWQMqw4CYPslAwJYSrlzFVW3o3E
      # https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/fe046bc7-4d68-4699-96c1-19aa464edff6/d8d6281-91959e92-214f-4b2d-a138-ace09f4b6d09.1080p.8e57939eba634743a9fa41185e398d00.mp4
      # https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/b1f96af6-56a3-47a8-b7f4-406f243af3a3/daihpha-9f1fcd2e-7557-4db5-951b-9aedca9a3ae7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTcwOTc0NzEzMCwiaWF0IjoxNzA5NzQ2NTIwLCJqdGkiOiI2NWU4YTk2MmVkNWQ1Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvYjFmOTZhZjYtNTZhMy00N2E4LWI3ZjQtNDA2ZjI0M2FmM2EzXC9kYWlocGhhLTlmMWZjZDJlLTc1NTctNGRiNS05NTFiLTlhZWRjYTlhM2FlNy5qcGcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.2L3RJYuC0hZA6qpNQ9k99Ns4EYqs67jZ8nrk19uKM_g&filename=legend_of_galactic_heroes_by_hideyoshi_daihpha.jpg
      in _, "wixmp.com", *rest
        fname = params[:filename]&.split(".")&.first.presence || filename
        parse_filename(fname)
        @jwt = parse_jwt(params[:token])
        @work_id ||= work_id_from_token

      # http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png
      # http://pre15.deviantart.net/81de/th/pre/f/2015/063/5/f/inha_by_inhaestudios-d8kfzm5.jpg
      # http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png
      # http://fc00.deviantart.net/fs71/f/2013/234/d/8/d84e05f26f0695b1153e9dab3a962f16-d6j8jl9.jpg
      # http://th04.deviantart.net/fs71/PRE/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg
      in _, "deviantart.net", *rest
        parse_filename(filename)

      # http://www.deviantart.com/download/135944599/Touhou___Suwako_Moriya_Colored_by_Turtle_Chibi.png
      # https://www.deviantart.com/download/549677536/countdown_to_midnight_by_kawacy-d939hwg.jpg?token=92090cd3910d52089b566661e8c2f749755ed5f8&ts=1438535525
      in _, "deviantart.com", "download", work_id, _
        parse_filename(filename)
        @work_id = work_id.to_i

      # https://www.deviantart.com/deviation/685436408
      # https://www.deviantart.com/view/685436408
      in _, "deviantart.com", ("deviation" | "view"), work_id
        @work_id = work_id.to_i

      # https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408
      # https://www.deviantart.com/noizave/art/685436408
      in _, "deviantart.com", username, "art", /^(?:([a-z0-9_-]+)-)?(\d+)$/i
        @username = username
        @title = $1
        @work_id = $2.to_i

      # https://noizave.deviantart.com/art/test-post-please-ignore-685436408
      in _, "deviantart.com", "art", /^([a-z0-9_-]+)-(\d+)$/i unless subdomain.in?(RESERVED_SUBDOMAINS)
        @username = subdomain
        @title = $1
        @work_id = $2.to_i

      # https://www.deviantart.com/view.php?id=14864502
      # https://www.deviantart.com/view-full.php?id=14864502
      in _, "deviantart.com", ("view.php" | "view-full.php") if params[:id]&.match?(/\A\d+\z/)
        @work_id = params[:id].to_i

      # https://www.deviantart.com/stash/0wxs31o7nn2
      in _, "deviantart.com", "stash", stash_id
        @stash_id = stash_id

      # https://www.deviantart.com/noizave
      # https://deviantart.com/noizave
      # https://www.deviantart.com/nlpsllp/gallery
      in _, "deviantart.com", username, *rest
        @username = username

      # https://noizave.deviantart.com
      # http://nemupanart.daportfolio.com
      # http://regi-chan.artworkfolio.com
      in _, ("deviantart.com" | "daportfolio.com" | "artworkfolio.com"), *rest unless subdomain.in?(RESERVED_SUBDOMAINS)
        @username = subdomain

      # https://fav.me/dbc3a48
      # https://www.fav.me/dbc3a48
      in _, "fav.me", /\Ad([a-z0-9]+)/i
        @work_id = $1.to_i(36)

      # https://sta.sh/21leo8mz87ue (folder)
      # https://sta.sh/2uk0v5wabdt (subfolder)
      # https://sta.sh/0wxs31o7nn2 (single image)
      # Ref: https://www.deviantartsupport.com/en/article/what-is-stash-3391708
      # Ref: https://www.deviantart.com/developers/http/v1/20160316/stash_item/4662dd8b10e336486ea9a0b14da62b74
      in _, "sta.sh", stash_id
        @stash_id = stash_id

      # https://sta.sh/zip/21leo8mz87ue
      in _, "sta.sh", "zip", stash_id
        @stash_id = stash_id

      else
        nil
      end
    end

    def parse_filename(filename)
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
      # https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/fe046bc7-4d68-4699-96c1-19aa464edff6/d8d6281-91959e92-214f-4b2d-a138-ace09f4b6d09.1080p.8e57939eba634743a9fa41185e398d00.mp4
      when /^d([a-z0-9]{6})-\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/
        @file = filename
        @work_id = $1.to_i(36)

      # http://www.deviantart.com/download/135944599/Touhou___Suwako_Moriya_Colored_by_Turtle_Chibi.png
      # http://th04.deviantart.net/fs70/300W/f/2009/364/4/d/Alphes_Mimic___Rika_by_Juriesute.png
      # http://img08.deviantart.net/bcb0/a/fit-in/300x900/filters:no_upscale():origin()/pre05/b9f5/th/pre/f/2009/364/4/d/alphes_mimic___rika_by_juriesute.png
      # http://fc02.deviantart.net/fs48/f/2009/186/2/c/Animation_by_epe_tohri.swf
      # http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg
      when /^(.+)_by_(.+)$/
        @file = filename
        @title = $1
        @username = $2.dasherize

      # http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg
      else
        @file = filename

      end
    end

    def parse_jwt(token)
      return {} if token.blank?

      header, payload = token.split(".").take(2).map { |data| Base64.decode64(data).parse_json }

      { header: header, payload: payload }.with_indifferent_access
    rescue JSON::ParserError
      {}
    end

    # Returns the path, width, and height permissions parsed from the JWT token:
    #
    # { "path": "/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg", "width": "<=786", "height": "<=1017" }
    # { "path": "/f/e46a48eb-3d0b-449e-90dc-0a1b31cb1361/dd3p1x9-fb47bc8f-653e-42a2-bb4d-afaf9fc2b781.jpg" }
    def jwt_permissions
      # https://api-da.wixmp.com/_api/download/file?downloadToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTU5MDkwMTUzMywiaWF0IjoxNTkwOTAwOTIzLCJqdGkiOiI1ZWQzMzhjNWQ5YjI0Iiwib2JqIjpudWxsLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdLCJwYXlsb2FkIjp7InBhdGgiOiJcL2ZcL2U0NmE0OGViLTNkMGItNDQ5ZS05MGRjLTBhMWIzMWNiMTM2MVwvZGQzcDF4OS1mYjQ3YmM4Zi02NTNlLTQyYTItYmI0ZC1hZmFmOWZjMmI3ODEuanBnIn19.-zo8E2eDmkmDNCK-sMabBajkaGtVYJ2Q20iVrUtt05Q
      # => https://jwt.io/#debugger-io?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTU5MDkwMTUzMywiaWF0IjoxNTkwOTAwOTIzLCJqdGkiOiI1ZWQzMzhjNWQ5YjI0Iiwib2JqIjpudWxsLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdLCJwYXlsb2FkIjp7InBhdGgiOiJcL2ZcL2U0NmE0OGViLTNkMGItNDQ5ZS05MGRjLTBhMWIzMWNiMTM2MVwvZGQzcDF4OS1mYjQ3YmM4Zi02NTNlLTQyYTItYmI0ZC1hZmFmOWZjMmI3ODEuanBnIn19.-zo8E2eDmkmDNCK-sMabBajkaGtVYJ2Q20iVrUtt05Q
      # => { ..., "payload": { "path": "/f/e46a48eb-3d0b-449e-90dc-0a1b31cb1361/dd3p1x9-fb47bc8f-653e-42a2-bb4d-afaf9fc2b781.jpg" }}
      #
      # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_75,strp/cc9686111dcffffffb5fcfaf0cf069fb.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi84YjQ3MmQ3MC1hMGQ2LTQxYjUtOWE2Ni1jMzU2ODcwOTBhY2MvZDIzamJyNC04YTA2YWYwMi03MGNiLTQ2ZGEtOGE5Ni00MmE2YmE3M2NkYjQuanBnIiwid2lkdGgiOiI8PTc4NiIsImhlaWdodCI6Ijw9MTAxNyJ9XV19.EXlDqS_4kMSDO26RTsuqE-H_XI0xSiO3dnAQRV6puqw
      # => https://jwt.io/#debugger-io?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi84YjQ3MmQ3MC1hMGQ2LTQxYjUtOWE2Ni1jMzU2ODcwOTBhY2MvZDIzamJyNC04YTA2YWYwMi03MGNiLTQ2ZGEtOGE5Ni00MmE2YmE3M2NkYjQuanBnIiwid2lkdGgiOiI8PTc4NiIsImhlaWdodCI6Ijw9MTAxNyJ9XV19.EXlDqS_4kMSDO26RTsuqE-H_XI0xSiO3dnAQRV6puqw
      # => { ..., "obj": [[{ "path": "/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg", "width": "<=786", "height": "<=1017" }]] }

      jwt.dig(:payload, :payload) || jwt.dig(:payload, :obj)&.flatten&.sole || {}
    end

    def jwt_path
      jwt_permissions[:path]
    end

    def max_width
      jwt_permissions[:width]&.delete_prefix("<=")&.to_i
    end

    def max_height
      jwt_permissions[:height]&.delete_prefix("<=")&.to_i
    end

    # Parse the deviation ID from the path in the JWT token.
    def work_id_from_token
      Source::URL.parse("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com#{jwt_path}").work_id if jwt_path
    end

    # Convert sample wixmp.com URLs to the best available version. Return nil for non-wixmp.com URLs.
    #
    # wixmp.com URLs that contain /v1/ are sample URLs. Some older images can be converted to larger /intermediary/
    # sample URLs. Otherwise the maximum image size is determined by the width/height restrictions in the JWT token.
    def full_image_url
      return nil unless image_url? && domain == "wixmp.com"

      if path.include?("/v1/") && work_id && work_id <= 790_677_560 && file_ext != "gif"
        # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/d8995973-0b32-4a7d-8cd8-d847d083689a/d797tit-1eac22e0-38b6-4eae-adcb-1b72843fd62a.png/v1/fill/w_720,h_1110,q_75,strp/goruto_by_xyelkiltrox-d797tit.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9kODk5NTk3My0wYjMyLTRhN2QtOGNkOC1kODQ3ZDA4MzY4OWEvZDc5N3RpdC0xZWFjMjJlMC0zOGI2LTRlYWUtYWRjYi0xYjcyODQzZmQ2MmEucG5nIiwid2lkdGgiOiI8PTcyMCIsImhlaWdodCI6Ijw9MTExMCJ9XV19.vSlSlntfQQ9qwJBv8mldhKRtllVAhUESfQfo6P0lHsU
        # => https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/d8995973-0b32-4a7d-8cd8-d847d083689a/d797tit-1eac22e0-38b6-4eae-adcb-1b72843fd62a.png
        "https://#{host}/intermediary#{path}".gsub(%r{/v1/.*}, "")
      elsif path.include?("/v1/") && max_width.present? && max_height.present?
        # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130,q_80,strp/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw
        # => https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw

        sample_options = "w_#{max_width},h_#{max_height}"
        sample_options += ",blur_#{jwt_permissions[:blur]}" if jwt_permissions[:blur].present?

        to_s.gsub(%r{/v1/[^/]+/[^/]+/}, "/v1/fill/#{sample_options}/")
      elsif path.include?("/v1/")
        to_s.gsub(%r{,q_\d+,strp/}, "/")
      else
        to_s
      end
    end

    def stash_url
      "https://sta.sh/#{stash_id}" if stash_id.present?
    end

    def page_url
      if stash_url.present?
        stash_url
      elsif username.present? && pretty_title.present? && work_id.present?
        "https://www.deviantart.com/#{username}/art/#{pretty_title}-#{work_id}"
      elsif work_id.present?
        "https://www.deviantart.com/deviation/#{work_id}"
      else
        nil
      end
    end

    # Most old image URLs redirect to new wixmp.com URLs. We can follow this redirect to find the page URL for old image
    # URLs that don't contain an ID.
    def page_url_from_redirect(http)
      if page_url.present?
        page_url

      # http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg
      # => https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ece2238f-5c8f-48e4-afda-304cab294acd/dwcohb-8189be91-691d-4212-b3a0-0b77e86a57d1.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9lY2UyMjM4Zi01YzhmLTQ4ZTQtYWZkYS0zMDRjYWIyOTRhY2QvZHdjb2hiLTgxODliZTkxLTY5MWQtNDIxMi1iM2EwLTBiNzdlODZhNTdkMS5qcGcifV1dfQ.eplvPT8qU7_a_dqiIfg_0S0540ihF-05iUQc5sn1bVM
      elsif image_url? && work_id.nil?
        url = http.cache(1.minute).redirect_url(self)
        Source::URL::DeviantArt.parse(url)&.page_url
      end
    end

    def image_url?
      file.present?
    end

    def profile_url
      "https://www.deviantart.com/#{username}" if username.present?
    end

    def pretty_title
      title.titleize.strip.squeeze(" ").tr(" ", "-") if title.present?
    end
  end
end
