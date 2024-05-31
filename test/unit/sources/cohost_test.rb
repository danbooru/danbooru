# frozen_string_literal: true

require "test_helper"

module Sources
  class CohostTest < ActiveSupport::TestCase
    context "Cohost:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png?width=675&auto=webp&dpr=1",
          image_urls: %w[https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png],
          media_files: [{ file_size: 2_802_737 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A full image URL" do
        strategy_should_work(
          "https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png",
          image_urls: %w[https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png],
          media_files: [{ file_size: 2_802_737 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A post" do
        strategy_should_work(
          "https://cohost.org/Karuu/post/2605252-nigiri-evil",
          image_urls: %w[https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png],
          media_files: [{ file_size: 2_802_737 }],
          page_url: "https://cohost.org/Karuu/post/2605252-nigiri-evil",
          profile_url: "https://cohost.org/Karuu",
          profile_urls: %w[https://cohost.org/Karuu],
          display_name: "Karu",
          username: "Karuu",
          tag_name: "karuu",
          other_names: ["Karu", "Karuu"],
          tags: [
            ["evil nigiri", "https://cohost.org/rc/tagged/evil nigiri"],
            ["oc", "https://cohost.org/rc/tagged/oc"],
            ["original character", "https://cohost.org/rc/tagged/original character"],
          ],
          dtext_artist_commentary_title: "nigiri (evil)",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A NSFW post with multiple images" do
        strategy_should_work(
          "https://cohost.org/aurahack18/post/2003123-my-finger-slipped-an",
          image_urls: %w[
            https://staging.cohostcdn.org/attachment/b9d29694-7b4b-4792-a364-1510a9729f75/catsk5%20(Custom).png
            https://staging.cohostcdn.org/attachment/18044bbd-defe-431d-a722-4d319fbb7dea/catsk6.png
          ],
          media_files: [
            { file_size: 4_201_231 },
            { file_size: 10_226_524 },
          ],
          page_url: "https://cohost.org/aurahack18/post/2003123-my-finger-slipped-an",
          profile_url: "https://cohost.org/aurahack18",
          profile_urls: %w[https://cohost.org/aurahack18],
          display_name: "Aura [NSFW MODE]",
          username: "aurahack18",
          tag_name: "aurahack18",
          other_names: ["Aura [NSFW MODE]", "aurahack18"],
          tags: [
            ["nsfw", "https://cohost.org/rc/tagged/nsfw"],
            ["hentai", "https://cohost.org/rc/tagged/hentai"],
            ["aurahack OC", "https://cohost.org/rc/tagged/aurahack OC"],
            ["catherine", "https://cohost.org/rc/tagged/catherine"],
            ["18+", "https://cohost.org/rc/tagged/18%2B"],
            ["Adult Artists On Cohost", "https://cohost.org/rc/tagged/Adult Artists On Cohost"],
            ["r18", "https://cohost.org/rc/tagged/r18"],
            ["rkgk", "https://cohost.org/rc/tagged/rkgk"],
            ["sketch", "https://cohost.org/rc/tagged/sketch"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            my finger slipped and drew more cat

            i was encouraged about drawing cat being used, this is your doing
          EOS
        )
      end

      context "A repost" do
        strategy_should_work(
          "https://cohost.org/Karuu/post/2409600-empty",
          image_urls: %w[],
          page_url: "https://cohost.org/Karuu/post/2409600-empty",
          profile_url: "https://cohost.org/Karuu",
          profile_urls: %w[https://cohost.org/Karuu],
          display_name: "Karu",
          username: "Karuu",
          tag_name: "karuu",
          other_names: ["Karu", "Karuu"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A repost that contains images of its own" do
        strategy_should_work(
          "https://cohost.org/DieselBrain/post/5289548-default-color-varian",
          image_urls: %w[
            https://staging.cohostcdn.org/attachment/0ac6e6f3-e568-4550-9075-94982ecf2c98/bridget%20pinup%204.png
            https://staging.cohostcdn.org/attachment/4a1b0e4c-f49d-428a-815e-4994356e109a/bridget%20pinup%205.png
            https://staging.cohostcdn.org/attachment/e91123a2-ea0f-4a69-be1b-609a786d84bc/bridget%20pinup%206.png
          ],
          media_files: [
            { file_size: 7_282_304 },
            { file_size: 7_280_715 },
            { file_size: 7_504_498 },
          ],
          page_url: "https://cohost.org/DieselBrain/post/5289548-default-color-varian",
          profile_url: "https://cohost.org/DieselBrain",
          profile_urls: %w[https://cohost.org/DieselBrain],
          display_name: nil,
          username: "DieselBrain",
          tag_name: "dieselbrain",
          other_names: ["DieselBrain"],
          tags: [
            ["bridget", "https://cohost.org/rc/tagged/bridget"],
            ["Bridget GG", "https://cohost.org/rc/tagged/Bridget GG"],
            ["bridget guilty gear", "https://cohost.org/rc/tagged/bridget guilty gear"],
            ["guilty gear", "https://cohost.org/rc/tagged/guilty gear"],
            ["guilty gear strive", "https://cohost.org/rc/tagged/guilty gear strive"],
            ["fighting games", "https://cohost.org/rc/tagged/fighting games"],
            ["fanart", "https://cohost.org/rc/tagged/fanart"],
            ["fgc", "https://cohost.org/rc/tagged/fgc"],
            ["boobs", "https://cohost.org/rc/tagged/boobs"],
            ["tits", "https://cohost.org/rc/tagged/tits"],
            ["breasts", "https://cohost.org/rc/tagged/breasts"],
            ["big boobs", "https://cohost.org/rc/tagged/big boobs"],
            ["big tits", "https://cohost.org/rc/tagged/big tits"],
            ["big breasts", "https://cohost.org/rc/tagged/big breasts"],
            ["big cock", "https://cohost.org/rc/tagged/big cock"],
            ["big penis", "https://cohost.org/rc/tagged/big penis"],
            ["big dick", "https://cohost.org/rc/tagged/big dick"],
            ["Thick Cock", "https://cohost.org/rc/tagged/Thick Cock"],
            ["thick penis", "https://cohost.org/rc/tagged/thick penis"],
            ["thick dick", "https://cohost.org/rc/tagged/thick dick"],
            ["big balls", "https://cohost.org/rc/tagged/big balls"],
            ["hentai", "https://cohost.org/rc/tagged/hentai"],
            ["porn", "https://cohost.org/rc/tagged/porn"],
            ["sexy", "https://cohost.org/rc/tagged/sexy"],
            ["Adult Artists On Cohost", "https://cohost.org/rc/tagged/Adult Artists On Cohost"],
            ["cohost after dark", "https://cohost.org/rc/tagged/cohost after dark"],
            ["artists on cohost after dark", "https://cohost.org/rc/tagged/artists on cohost after dark"],
            ["Dieselbrain Art", "https://cohost.org/rc/tagged/Dieselbrain Art"],
          ],
          dtext_artist_commentary_title: "default color variant",
          dtext_artist_commentary_desc: <<~EOS.chomp
            If you like the work i do, supporting me in some way below really does help a lot!

            * "PATREON":[https://www.patreon.com/Dieselbrain]
            * "STICKER CLUB":[https://docs.google.com/forms/d/e/1FAIpQLSfY3lT1ZPoEhaf-HdriHjfUXuEGfTy0zlZSAl1mArU4v-OYcw/viewform]
            * "COMM INFO":[https://docs.google.com/document/d/1kJ2WHYsu54jfFTHHiJQV0PCHP2HPDAx7ypwmanEAKHY/edit]
            * "FOLLOW ME ELSEWHERE":[https://barberadieselbrain.carrd.co/]
          EOS
        )
      end

      context "A login-only post" do
        strategy_should_work(
          "https://cohost.org/VCRStatic/post/5740213-just-realised-that-a",
          image_urls: %w[https://staging.cohostcdn.org/attachment/ab9ecde9-50a2-4e3d-b916-fe8b5830536a/IMG_2071.gif],
          media_files: [{ file_size: 296_661 }],
          page_url: "https://cohost.org/VCRStatic/post/5740213-just-realised-that-a",
          profile_url: "https://cohost.org/VCRStatic",
          profile_urls: %w[https://cohost.org/VCRStatic],
          display_name: "Pretty Boy Vee",
          username: "VCRStatic",
          tag_name: "vcrstatic",
          other_names: ["Pretty Boy Vee", "VCRStatic"],
          tags: [
            ["Vee Art", "https://cohost.org/rc/tagged/Vee Art"],
            ["Vee Rambles", "https://cohost.org/rc/tagged/Vee Rambles"],
            ["Artist", "https://cohost.org/rc/tagged/Artist"],
            ["art", "https://cohost.org/rc/tagged/art"],
            ["lioden", "https://cohost.org/rc/tagged/lioden"],
            ["lion", "https://cohost.org/rc/tagged/lion"],
            ["gif", "https://cohost.org/rc/tagged/gif"],
            ["animation", "https://cohost.org/rc/tagged/animation"],
            ["animated", "https://cohost.org/rc/tagged/animated"],
            ["furry", "https://cohost.org/rc/tagged/furry"],
            ["furry art", "https://cohost.org/rc/tagged/furry art"],
            ["fursona", "https://cohost.org/rc/tagged/fursona"],
            ["animal art", "https://cohost.org/rc/tagged/animal art"],
            ["animal", "https://cohost.org/rc/tagged/animal"],
            ["feral", "https://cohost.org/rc/tagged/feral"],
            ["feral art", "https://cohost.org/rc/tagged/feral art"],
            ["ArtistsOnCohost", "https://cohost.org/rc/tagged/ArtistsOnCohost"],
            ["artists on cohost", "https://cohost.org/rc/tagged/artists on cohost"],
            ["The Global Cohost Feed", "https://cohost.org/rc/tagged/The Global Cohost Feed"],
            ["The Cohost Global Feed", "https://cohost.org/rc/tagged/The Cohost Global Feed"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Just realised that all my silly lion doodles will be great for my portfolio when i apply for the art degree 👀
          EOS
        )
      end

      context "A post with a Youtube embed" do
        strategy_should_work(
          "https://cohost.org/AnalogueSheep/post/5753536-atrioc-the-billiona",
          image_urls: [],
          page_url: "https://cohost.org/AnalogueSheep/post/5753536-atrioc-the-billiona",
          profile_url: "https://cohost.org/AnalogueSheep",
          profile_urls: %w[https://cohost.org/AnalogueSheep],
          display_name: "Analogue Sheep",
          username: "AnalogueSheep",
          tag_name: "analoguesheep",
          other_names: ["Analogue Sheep", "AnalogueSheep"],
          tags: [
            ["bluey", "https://cohost.org/rc/tagged/bluey"],
            ["business", "https://cohost.org/rc/tagged/business"],
            ["Joe Brumm", "https://cohost.org/rc/tagged/Joe Brumm"],
            ["Ludo Studio", "https://cohost.org/rc/tagged/Ludo Studio"],
            ["disney", "https://cohost.org/rc/tagged/disney"],
            ["bbc", "https://cohost.org/rc/tagged/bbc"],
            ["animation", "https://cohost.org/rc/tagged/animation"],
            ["2d animation", "https://cohost.org/rc/tagged/2d animation"],
            ["Australian Broadcasting Corporation", "https://cohost.org/rc/tagged/Australian Broadcasting Corporation"],
            ["australia", "https://cohost.org/rc/tagged/australia"],
            ["capitalism", "https://cohost.org/rc/tagged/capitalism"],
            ["copyright", "https://cohost.org/rc/tagged/copyright"],
            ["Atrioc", "https://cohost.org/rc/tagged/Atrioc"],
            ["streaming", "https://cohost.org/rc/tagged/streaming"],
          ],
          dtext_artist_commentary_title: "Atrioc - The Billion Dollar War for \"Bluey\"",
          dtext_artist_commentary_desc: "https://youtu.be/ylj6fHhFUjY?si=Hg9YL_TQo3lOHUNp"
        )
      end

      context "A post in reply to a non-anonymous ask" do
        strategy_should_work(
          "https://cohost.org/charmyte/post/5722494-two-giggly-birds-fla",
          image_urls: %w[https://staging.cohostcdn.org/attachment/cb0ce55c-2b3d-4b9e-9269-c4e9110e58ae/image.webp],
          media_files: [{ file_size: 130_462 }],
          page_url: "https://cohost.org/charmyte/post/5722494-two-giggly-birds-fla",
          profile_url: "https://cohost.org/charmyte",
          profile_urls: %w[https://cohost.org/charmyte],
          display_name: "Kobold Girl Tailtuft",
          username: "charmyte",
          tag_name: "charmyte",
          other_names: ["Kobold Girl Tailtuft", "charmyte"],
          tags: [
            ["ask", "https://cohost.org/rc/tagged/ask"],
            ["birdevil", "https://cohost.org/rc/tagged/birdevil"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            [quote]
            birdbirdbeak asked:

            ourple :) babybel wrapper
            [/quote]

            Two giggly birds flapping between the trees
          EOS
        )
      end

      context "A post in reply to an anonymous user ask" do
        strategy_should_work(
          "https://cohost.org/xenopavilia/post/5743202-really-good-pairing",
          image_urls: %w[https://staging.cohostcdn.org/attachment/9f9c44c3-6004-4d06-9f7b-2559af550965/vriska%20kanaya%20impreg.png],
          media_files: [{ file_size: 65_362 }],
          page_url: "https://cohost.org/xenopavilia/post/5743202-really-good-pairing",
          profile_url: "https://cohost.org/xenopavilia",
          profile_urls: %w[https://cohost.org/xenopavilia],
          display_name: "Xenophilia",
          username: "xenopavilia",
          tag_name: "xenopavilia",
          other_names: ["Xenophilia", "xenopavilia"],
          tags: [
            ["homestuck", "https://cohost.org/rc/tagged/homestuck"],
            ["homesmut", "https://cohost.org/rc/tagged/homesmut"],
            ["nsfw", "https://cohost.org/rc/tagged/nsfw"],
            ["art", "https://cohost.org/rc/tagged/art"],
            ["ask", "https://cohost.org/rc/tagged/ask"],
            ["vriska", "https://cohost.org/rc/tagged/vriska"],
            ["kanaya", "https://cohost.org/rc/tagged/kanaya"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            [quote]
            Anonymous User asked:

            thoughts on vriskan?:)
            [/quote]

            really good pairing. big fan of big bitch brats getting their way
          EOS
        )
      end

      context "A post in reply to an anonymous guest ask" do
        strategy_should_work(
          "https://cohost.org/WelcomeTaco/post/5693109-mostly-it-s-just-a",
          image_urls: %w[https://staging.cohostcdn.org/attachment/61513587-6324-4d1a-8c2e-ed815b24933b/image.png],
          media_files: [{ file_size: 354_705 }],
          page_url: "https://cohost.org/WelcomeTaco/post/5693109-mostly-it-s-just-a",
          profile_url: "https://cohost.org/WelcomeTaco",
          profile_urls: %w[https://cohost.org/WelcomeTaco],
          display_name: "WT (Master Cards era)",
          username: "WelcomeTaco",
          tag_name: "welcometaco",
          other_names: ["WT (Master Cards era)", "WelcomeTaco"],
          tags: [
            ["ask", "https://cohost.org/rc/tagged/ask"],
            ["bat", "https://cohost.org/rc/tagged/bat"],
            ["curator", "https://cohost.org/rc/tagged/curator"],
            ["mr biography", "https://cohost.org/rc/tagged/mr biography"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            [quote]
            Anonymous Guest asked:

            Something I've been wondering: is there any particular reason why you gave your Curators very un-batlike long fluffy tails or was it just because you thought it was cuter or whatever?
            [/quote]

            Mostly, it's just a personal preference for a cute and fluffy tail, and the thought that a fluffy tail with the softness of a bat would be very pleasant to touch. It's also for the thought of there being a bit of variation in how they're able to present, with both a smaller form (1 and 2) for casual life and interaction with smaller beings. There's also high wilderness mode (3) which is overall larger, has more wings, a tail membrane, and dark starry fur for camouflage. The interior membrane of the wings is brighter and swirls and gleams, providing a sight to mesmerize prey. The feet are also 'rotated to be backwards' for better prey catching.

            For 1 and 2, standing like 1 is a more natural pose with the weight supported on the muscular wing-arms and hind feet. 2 is standing on the hind feet (in smaller form, 'rotated to be forward') and is less comfortable, and I think contributes to why the Masters are so pissed off all the time.

            I do draw a few Curators with more batlike tails, those being collaborative OC Poppy, friend Len's Mr. Games, Ash, and Mr. Hues. I do very love a bat-like tail, but a fluffy tail is simply too much for my gay little heart to resist.
          EOS
        )
      end

      context "A commentary that contains Markdown links, lists, and <details> tags" do
        strategy_should_work(
          "https://cohost.org/fish/post/5667297-you-have-come-to-the",
          image_urls: [],
          page_url: "https://cohost.org/fish/post/5667297-you-have-come-to-the",
          profile_url: "https://cohost.org/fish",
          profile_urls: %w[https://cohost.org/fish],
          display_name: nil,
          username: "fish",
          tag_name: "fish",
          other_names: ["fish"],
          tags: [
            ["Illuminated Manuscript", "https://cohost.org/rc/tagged/Illuminated Manuscript"],
            ["manuscript", "https://cohost.org/rc/tagged/manuscript"],
            ["ask", "https://cohost.org/rc/tagged/ask"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            [quote]
            isyourguy asked:

            where are you getting your manuscripts these days? of all the people on here i know you've got a secret stash somewhere…
            [/quote]

            you have come to the right place, fellow manuscript peruser…

            highlights (single books)

            * "the black hours":[https://www.themorgan.org/collection/Black-Hours/thumbs]
            * "the crusader bible":[https://www.themorgan.org/collection/Crusader-Bible/thumbs]
            * "the hours of jeanne d'evreux":[https://www.metmuseum.org/art/collection/search/470309]
            * "the belles heures":[https://www.metmuseum.org/art/collection/search/470306]
            * i would put the book of kells on here but the link is apparently broken. sad!

            [expand=digitized manuscript collections]
            * "digitized medieval manuscripts database":[https://digitizedmedievalmanuscripts.org/data][br] database of online libraries with digitized manuscripts, so a collection of collections. has a "random library" button if you feel overwhelmed.
            * "the morgan library":[https://www.themorgan.org/manuscripts/list][br] good place to start for whole books from the middle ages/early modern era. interface is nice and simple.
            * "getty":[https://www.getty.edu/art/collection/search?classification=Illuminated+Manuscript&images=true][br] great if you just want to browse illustrations
            * "digital library of medieval manuscripts":[https://dlmm.library.jhu.edu/viewer/#dlmm][br] johns hopkins university collection, has helpful thumbnails on its search page
            * "digital bodleian":[https://digital.bodleian.ox.ac.uk/browse/][br] manuscripts from all around the world
            * "cambridge digital library":[https://cudl.lib.cam.ac.uk/collections/][br] has many collections, grouped by language and topic
            * "wren digital library":[https://www.trin.cam.ac.uk/library/wren-digital-library/][br] trinity college collection of european manuscripts, nice search system
            * "goodspeed manuscript collection":[https://goodspeed.lib.uchicago.edu/][br] greek, syriac, ethiopic, armenian, arabic, and latin manuscripts from the 5th–19th centuries
            * "KBR digitised collection":[https://belgica.kbr.be/belgica/default.aspx?_lg=en-GB][br] royal library of belgium collection
            * "irish script on screen":[https://www.isos.dias.ie/index.html][br] largest digital collection of irish manuscripts
            [/expand]
          EOS
        )
      end

      context "A commentary that contains Markdown headers, lists, <hr> tags, and <details> tags" do
        strategy_should_work(
          "https://cohost.org/waste/post/5680704-hi-im-glad-you-asked",
          image_urls: [],
          page_url: "https://cohost.org/waste/post/5680704-hi-im-glad-you-asked",
          profile_url: "https://cohost.org/waste",
          profile_urls: %w[https://cohost.org/waste],
          display_name: "Gears",
          username: "waste",
          tag_name: "waste",
          tags: [
            ["aplatonic", "https://cohost.org/rc/tagged/aplatonic"],
            ["Queer", "https://cohost.org/rc/tagged/Queer"],
            ["ask", "https://cohost.org/rc/tagged/ask"],
          ],
          dtext_artist_commentary_title: "hi im glad you asked!!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            [quote]
            Anonymous User asked:

            what exactly does aplatonic mean
            [/quote]

            h4. what is aplatonic?

            similar to the concepts of aromanticism and asexuality, [b][i]aplatonic[/i][/b] essentially means that an individual a) lacks a desire to have friendships or b) does not experience platonic attraction

            [expand=but … what is platonic attraction (friendship) anyway?]
            how i see it, it's wanting to form a deep or close bond with someone, such as by sharing things in common and wanting to spend more time with the other, usually without a desire for physical intimacy.

            "platonic attraction" originates from Plato's ideals that platonic [i]love,[/i] one that is without sexual intimacy, brings people to an ideal society
            [/expand]

            h5. 't is a spectrum

            [hr]

            "platonic love" is considered ambiguous, and just like aromantics and asexuals, no two aplatonics are the same! one may lack the love for or bond with one's friends while still being ok with having friends , while another may want to avoid friendships altogether. those are just a few of the many many different ways to experience aplatonicism

            h6. how i experience it, as far as i'm currently aware, is:

            * i prefer having [i]acquaintances[/i] (people i consistently see at a specific place) over friends, people who want to hang out with me constantly no matter where i'm at
            * ~~ok i just found out that "familial attraction" automatically implies incest, so~~ if theres a word for seeing non-family members As Family then yeah. wait there is a word it's called kinship. Yeah. ok so
            * i can experience kinship with non-family members, especially with other filipinos since it's basically our culture. like i'll get excited to see my kuya (older bro, or another term of respect for a man who is a little older than me)
            * im ok with having friends; i don't have the desire to be close, especially emotionally and physically, to them
            * i identify as aplspec (part of the aplatonic spectrum) … because while specific labels would be helpful i don't really bother with em
            * my aplatonicism may be affected by my neurodivergence &or trauma ^_^
            * sometimes i will desire to be friends with someone, and then the desire goes away when it's reciprocated … lel
            * also im gonna vaguely say rhat i have a love for the world and for peopel in a broad sense, and it doesnt change my platonic attraction

            as with anyqueer … all this may be subject to change in the future, i have only begun using this term recently

            h6. any more questions are welcome ! i'll try to explain things to the best of my ability … thank you!
          EOS
        )
      end

      context "A post with embedded images in the commentary" do
        strategy_should_work(
          "https://cohost.org/aurahack18/post/2040961-pov-you-re-in-the-o",
          image_urls: [],
          media_files: [],
          page_url: "https://cohost.org/aurahack18/post/2040961-pov-you-re-in-the-o",
          profile_url: "https://cohost.org/aurahack18",
          profile_urls: %w[https://cohost.org/aurahack18],
          display_name: "Aura [NSFW MODE]",
          username: "aurahack18",
          tag_name: "aurahack18",
          other_names: ["Aura [NSFW MODE]", "aurahack18"],
          tags: [
            ["aura18OC", "https://cohost.org/rc/tagged/aura18OC"],
            ["catherine", "https://cohost.org/rc/tagged/catherine"],
            ["nsfw", "https://cohost.org/rc/tagged/nsfw"],
            ["hentai", "https://cohost.org/rc/tagged/hentai"],
            ["r18", "https://cohost.org/rc/tagged/r18"],
            ["18+", "https://cohost.org/rc/tagged/18%2B"],
            ["Adult Artists On Cohost", "https://cohost.org/rc/tagged/Adult Artists On Cohost"],
            ["POV", "https://cohost.org/rc/tagged/POV"],
          ],
          dtext_artist_commentary_title: "POV: You're in the office after-hours getting to see how Cat motivates her team",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://cdn.discordapp.com/attachments/847276749788151829/1129283113990750260/cat_work1.png]

            "[image]":[https://cdn.discordapp.com/attachments/847276749788151829/1129283115345518662/cat_work2.png]

            She's hard at work!
            Please give her badge back, though. It's got high clearance and she'll get in actual trouble if you keep it >:T
          EOS
        )
      end

      context "A deleted or nonexistent post" do
        strategy_should_work(
          "https://cohost.org/nobody/post/999999999-title",
          image_urls: %w[],
          media_files: [],
          page_url: "https://cohost.org/nobody/post/999999999-title",
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse URLs correctly" do
        assert(Source::URL.image_url?("https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png?width=675&auto=webp&dpr=1"))
        assert(Source::URL.image_url?("https://staging.cohostcdn.org/header/42892-7cd2e652-82fd-464d-b544-4bdd4bea429a-profile.jpeg"))
        assert(Source::URL.image_url?("https://staging.cohostcdn.org/avatar/42892-471e51cc-d0d5-4e86-a52c-eec635fc4a2c-profile.gif?dpr=2&width=80&height=80&fit=cover&auto=webp"))

        assert(Source::URL.page_url?("https://cohost.org/Karuu/post/2605252-nigiri-evil"))

        assert(Source::URL.profile_url?("https://cohost.org/Karuu"))

        assert_equal("https://cohost.org/Karuu", Source::URL.profile_url("https://cohost.org/Karuu/post/2605252-nigiri-evil"))
      end
    end
  end
end
