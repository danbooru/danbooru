require "test_helper"

module Source::Tests::Extractor
  class MinitokyoExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Minitokyo sample image URL" do
      strategy_should_work(
        "http://static1.minitokyo.net/thumbs/42/26/571342-2.jpg",
        image_urls: %w[http://static.minitokyo.net/downloads/42/26/571342-2.jpg],
        media_files: [{ file_size: 1_360_479 }],
        page_url: "http://gallery.minitokyo.net/view/571342",
        profile_url: "http://cilou.minitokyo.net/",
        profile_urls: %w[http://cilou.minitokyo.net/],
        display_name: "Cilou",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["Kurehito Misaki", "http://www.minitokyo.net/Kurehito+Misaki"],
          ["Touhou", "http://www.minitokyo.net/Touhou"],
          ["Flandre Scarlet", "http://www.minitokyo.net/Flandre+Scarlet"],
          ["Vector Art", "http://www.minitokyo.net/Vector+Art"],
        ],
        dtext_artist_commentary_title: "Kurehito Misaki Wallpaper: Lady Vengeance",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Hi! I made this wall from this gorgeous scan of Scampi
          "(C81) Alstroemeria Records - KILLED DANCEHALL":[http://gallery.minitokyo.net/view/568499]

          Isn't it so beautiful? I love the design of Kurehito Misaki... so I made the vector!

          I wanted to make an empty wall to increase the feeling of cold and solitude, but I finally made several versions, more or less satured, added some elements on some, played with colors and contrast.

          I've no idea for a good title, so if you have, it's welcome!

          I hope you'll like!
        EOS
      )
    end

    context "A Minitokyo full image URL" do
      strategy_should_work(
        "http://static.minitokyo.net/downloads/18/45/704768.jpg",
        image_urls: %w[http://static.minitokyo.net/downloads/18/45/704768.jpg],
        media_files: [{ file_size: 2_842_457 }],
        page_url: "http://gallery.minitokyo.net/view/704768",
        profile_url: "http://deto15.minitokyo.net/",
        profile_urls: %w[http://deto15.minitokyo.net/],
        display_name: "Deto15",
        username: nil,
        published_at: nil,
        updated_at: nil,
        # tags: [
        #   ["Yuusuke Murata", "http://www.minitokyo.net/Yuusuke+Murata"],
        #   ["Madhouse", "http://www.minitokyo.net/Madhouse"],
        #   ["Onepunch-Man", "http://www.minitokyo.net/Onepunch-Man"],
        #   ["Sonic (Onepunch-man)", "http://www.minitokyo.net/Sonic+%28Onepunch-man%29"],
        #   ["Genos", "http://www.minitokyo.net/Genos"],
        # ],
        dtext_artist_commentary_title: "Onepunch-Man Wallpaper: Much Punches",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Manual for using this wallpaper - PLEASE READ ME!

          A manual for wallpaper? Yup, trust me, it might be useful in this case.
          There's a lot of grain on this wallpaper; it's an artistic choice that I've been aiming for from the start and I've composed this wallpaper around it. The thing with grain is that even the slightest drop in quality will be noticeable and can create graphical artifacts like you GPU is melting.

          With that in mind:
          - very sorry to say this but be wary ot using the version of wallpaper that is submitted here on MiniTokyo. Sadly MT doesn't allow the upload of superior PNG files, only JPG. Regardless of whether the MT itself reduced upload quality or not, Windows does. Yup, currently in Windows 10 if you use JPG file as wallpaper, Windows itself will drop it quality slightly, no matter if you choose to fill, center or whatever. Sadly, this slight drop is noticeable with grain so if you want it to look good get the PNG version from my website <http://www.brokentone.net/wall/162-much-punches/> . Or if you hate me for making you crawl through my website, you can get it directly from here <http://i.imgur.com/XqyH9v5.png> . Btw, I'm speaking about WIndows 10 because I have Windows 10; I assume some of older Windowses or other systems might not have that problem so you can test.
          - if you'll ever be reposting this somewhere, please don't convert it to JPG. Windows 10 (and possibly some older) hates JPG and by default lowers the quality of wallpapers slightly. It just won't look well as JPG, no matter if you fill, center or whatever.
          - even if you get it in PNG, I recommend to get it in a size that is right for your screen, and then set it to be centered - that should give you the best result.
          - if you're using Windows 10 with Microsoft Account on multiple PCs, Windows by default shares your wallpaper between your computer. Yup, that will tear it to shreds too. So if you want to stop it from sharing it, here's a little bit about that <http://www.howtogeek.com/222110/understanding-the-new-sync-settings-in-windows-10/>

          And here's a link to the best edition of wall, static noise edition <http://i.imgur.com/IwkSMqI.gif> . Ah, I'm so happy with how this one came out x3
          Windows by default doesn't let you have animated GIF as wallpaper, but here's a small cute program that makes it possible <http://www.bionixwallpaper.com/downloads/Animated%20Desktop%20Wallpaper/index.html>
          I recommend setting animation speed at 60-70, I think that feels about right.

          Now about the wall
          Most of elements were vectored from anime screenshot, just few parts from manga.
          Took quite a long time but was pretty fun.
          Hope you like!
        EOS
      )
    end

    context "A Minitokyo wallpaper post" do
      strategy_should_work(
        "http://gallery.minitokyo.net/view/704768",
        image_urls: %w[http://static.minitokyo.net/downloads/18/45/704768.jpg],
        media_files: [{ file_size: 2_842_457 }],
        page_url: "http://gallery.minitokyo.net/view/704768",
        profile_url: "http://deto15.minitokyo.net/",
        profile_urls: %w[http://deto15.minitokyo.net/],
        display_name: "Deto15",
        username: nil,
        published_at: Time.parse("2016-09-28T00:00:00.000000Z"),
        updated_at: nil,
        # XXX Can't test the tags because they're unstable; Minitokyo randomly returns different tags for the same post
        # tags: [
        #   ["Yuusuke Murata", "http://www.minitokyo.net/Yuusuke+Murata"],
        #   ["Madhouse", "http://www.minitokyo.net/Madhouse"],
        #   ["Onepunch-Man", "http://www.minitokyo.net/Onepunch-Man"],
        #   ["Sonic (Onepunch-man)", "http://www.minitokyo.net/Sonic+%28Onepunch-man%29"],
        #   ["Genos", "http://www.minitokyo.net/Genos"],
        # ],
        dtext_artist_commentary_title: "Onepunch-Man Wallpaper: Much Punches",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Manual for using this wallpaper - PLEASE READ ME!

          A manual for wallpaper? Yup, trust me, it might be useful in this case.
          There's a lot of grain on this wallpaper; it's an artistic choice that I've been aiming for from the start and I've composed this wallpaper around it. The thing with grain is that even the slightest drop in quality will be noticeable and can create graphical artifacts like you GPU is melting.

          With that in mind:
          - very sorry to say this but be wary ot using the version of wallpaper that is submitted here on MiniTokyo. Sadly MT doesn't allow the upload of superior PNG files, only JPG. Regardless of whether the MT itself reduced upload quality or not, Windows does. Yup, currently in Windows 10 if you use JPG file as wallpaper, Windows itself will drop it quality slightly, no matter if you choose to fill, center or whatever. Sadly, this slight drop is noticeable with grain so if you want it to look good get the PNG version from my website <http://www.brokentone.net/wall/162-much-punches/> . Or if you hate me for making you crawl through my website, you can get it directly from here <http://i.imgur.com/XqyH9v5.png> . Btw, I'm speaking about WIndows 10 because I have Windows 10; I assume some of older Windowses or other systems might not have that problem so you can test.
          - if you'll ever be reposting this somewhere, please don't convert it to JPG. Windows 10 (and possibly some older) hates JPG and by default lowers the quality of wallpapers slightly. It just won't look well as JPG, no matter if you fill, center or whatever.
          - even if you get it in PNG, I recommend to get it in a size that is right for your screen, and then set it to be centered - that should give you the best result.
          - if you're using Windows 10 with Microsoft Account on multiple PCs, Windows by default shares your wallpaper between your computer. Yup, that will tear it to shreds too. So if you want to stop it from sharing it, here's a little bit about that <http://www.howtogeek.com/222110/understanding-the-new-sync-settings-in-windows-10/>

          And here's a link to the best edition of wall, static noise edition <http://i.imgur.com/IwkSMqI.gif> . Ah, I'm so happy with how this one came out x3
          Windows by default doesn't let you have animated GIF as wallpaper, but here's a small cute program that makes it possible <http://www.bionixwallpaper.com/downloads/Animated%20Desktop%20Wallpaper/index.html>
          I recommend setting animation speed at 60-70, I think that feels about right.

          Now about the wall
          Most of elements were vectored from anime screenshot, just few parts from manga.
          Took quite a long time but was pretty fun.
          Hope you like!
        EOS
      )
    end

    context "A Minitokyo scan post" do
      strategy_should_work(
        "http://gallery.minitokyo.net/view/27707",
        image_urls: %w[http://static.minitokyo.net/downloads/07/04/27707.jpg],
        media_files: [{ file_size: 1_465_036 }],
        page_url: "http://gallery.minitokyo.net/view/27707",
        profile_url: "http://slay_x.minitokyo.net/",
        profile_urls: %w[http://slay_x.minitokyo.net/],
        display_name: "slay_x",
        username: nil,
        published_at: Time.parse("2004-07-18T00:00:00.000000Z"),
        updated_at: nil,
        tags: [
          ["Kenichi Sonoda", "http://www.minitokyo.net/Kenichi+Sonoda"],
          ["Riding Bean", "http://www.minitokyo.net/Riding+Bean"],
        ],
        dtext_artist_commentary_title: "Riding Bean: Cars Cars Cars",
        dtext_artist_commentary_desc: "Riding Bean again. This time a collage of cars, mostly American muscle cars like the Ford Shelby and Corvettes, plus others like the Alfa Romeo and of course, yours truly, The Roadbuster! Scanned from Kenichi Sonoda's Artbook by DPG.",
      )
    end

    context "A Minitokyo download URL" do
      strategy_should_work(
        "http://gallery.minitokyo.net/download/332089",
        image_urls: %w[http://static.minitokyo.net/downloads/39/41/332089.jpg],
        media_files: [{ file_size: 536_136 }],
        page_url: "http://gallery.minitokyo.net/view/332089",
        profile_url: "http://sammo.minitokyo.net/",
        profile_urls: %w[http://sammo.minitokyo.net/],
        display_name: "sammo",
        username: nil,
        published_at: Time.parse("2008-02-16T00:00:00.000000Z"),
        updated_at: nil,
        tags: [
          ["Memories Off", "http://www.minitokyo.net/Memories+Off"],
          ["Inori Misasagi", "http://www.minitokyo.net/Inori+Misasagi"],
        ],
        dtext_artist_commentary_title: "Memories Off Wallpaper: Memories Off - Unstolen Jewel",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          as some of you may be aware/not aware, my dear home imanimetions.net is no longer alive! shinta has done a fantastic job keeping the site alive for such a long time since the dawn of anime wallpaper ages, but its time for every one to move on.

          unfortunately, i still need a place to archive my doodies, and i thought uploading it back on minitokyo would be a great place to do it.

          its an old wall; i got the title of the wallpaper from chrono cross, color scheme idea from one of kaguya's beatiful artwork. looking back at it, i REALLY wish i had not placed that text on the wallpaper, i think it would've looked much better textless... but the psd is long gone, so it can't be helped.

          critique, comments, all appreciated :]
        EOS
      )
    end

    context "A Minitokyo multi-image post" do
      strategy_should_work(
        "http://gallery.minitokyo.net/view/571342",
        image_urls: %w[
          http://static.minitokyo.net/downloads/42/26/571342.jpg
          http://static.minitokyo.net/downloads/42/26/571342-1.jpg
          http://static.minitokyo.net/downloads/42/26/571342-2.jpg
          http://static.minitokyo.net/downloads/42/26/571342-3.jpg
        ],
        media_files: [
          { file_size: 1_680_789 },
          { file_size: 2_472_777 },
          { file_size: 1_360_479 },
          { file_size: 1_900_625 },
        ],
        page_url: "http://gallery.minitokyo.net/view/571342",
        profile_url: "http://cilou.minitokyo.net/",
        profile_urls: %w[http://cilou.minitokyo.net/],
        display_name: "Cilou",
        username: nil,
        published_at: Time.parse("2012-01-22T00:00:00.000000Z"),
        updated_at: nil,
        tags: [
          ["Kurehito Misaki", "http://www.minitokyo.net/Kurehito+Misaki"],
          ["Touhou", "http://www.minitokyo.net/Touhou"],
          ["Flandre Scarlet", "http://www.minitokyo.net/Flandre+Scarlet"],
          ["Vector Art", "http://www.minitokyo.net/Vector+Art"],
        ],
        dtext_artist_commentary_title: "Kurehito Misaki Wallpaper: Lady Vengeance",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Hi! I made this wall from this gorgeous scan of Scampi
          "(C81) Alstroemeria Records - KILLED DANCEHALL":[http://gallery.minitokyo.net/view/568499]

          Isn't it so beautiful? I love the design of Kurehito Misaki... so I made the vector!

          I wanted to make an empty wall to increase the feeling of cold and solitude, but I finally made several versions, more or less satured, added some elements on some, played with colors and contrast.

          I've no idea for a good title, so if you have, it's welcome!

          I hope you'll like!
        EOS
      )
    end

    context "A non-existent Minitokyo post" do
      strategy_should_work(
        "http://gallery.minitokyo.net/view/999999999",
        image_urls: [],
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A 'removed from the gallery' Minitokyo post" do
      strategy_should_work(
        "http://gallery.minitokyo.net/view/2",
        image_urls: [],
        page_url: "http://gallery.minitokyo.net/view/2",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A 'deleted, doesn't exist, pending approval' Minitokyo post" do
      strategy_should_work(
        "http://gallery.minitokyo.net/view/778333",
        image_urls: [],
        page_url: "http://gallery.minitokyo.net/view/778333",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A Minitokyo artist profile URL" do
      strategy_should_work(
        "http://deto15.minitokyo.net",
        image_urls: [],
        profile_url: "http://deto15.minitokyo.net",
        profile_urls: %w[http://deto15.minitokyo.net],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: nil,
        page_url: nil,
      )
    end
  end
end
