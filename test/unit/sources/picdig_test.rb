require "test_helper"

module Sources
  class PicdigTest < ActiveSupport::TestCase
    context "Picdig:" do
      context "A Picdig project URL" do
        strategy_should_work(
          "https://picdig.net/ema/projects/9d99151f-6d3e-4084-9cc0-082d386122ca",
          image_urls: %w[
            https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/42163c7d-16cb-4665-867e-f62b8133359d.png
            https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/7954f986-e471-4d41-9d06-16a1a695b42d.png
            https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/f921c899-b5f5-410b-8b4b-8287047f6b80.png
          ],
          profile_url: "https://picdig.net/ema/portfolio",
          profile_urls: %w[
            https://picdig.net/ema/portfolio
            https://twitter.com/Ema_azure
            https://www.pixiv.net/users/41875383
          ],
          page_url: "https://picdig.net/ema/projects/9d99151f-6d3e-4084-9cc0-082d386122ca",
          display_name: "絵馬",
          username: "ema",
          other_names: ["絵馬", "ema"],
          artist_commentary_title: "「わたしの季節」",
          dtext_artist_commentary_desc: "「わたしの季節」このイラストのコンセプトや構図・配色についてご紹介！イラストコンセプト：''わたしの''秋イラストテーマは秋。秋のキャラクターイラストを思い浮かべるとき多くの人は秋の景色の中にいるキャラクターを連想すると思います。しかしこのイラストは　秋の中にいるわたし　ではなく、「わたしの季節こそが秋なんだ！」そんなメッセージを込めて描いています。あくまで主役はキャラクター。だからこそキャラクターに自然と目線が向かうように構図や配色を考えました。日々勉強中ではありますが、大枠をこんな感じで考えて描いたイラストです(^^)本ページはここまで！お目通しありがとうございましたー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー水色の絵馬キャラクターイラストのお仕事をメインに募集中です。稚拙ではありますが背景付きのイラストも描いております。TwitterやPixivにも多くのイラストを成長の記録として掲載していますので気になる方はぜひご覧下さいね",
          tags: [
            %w[かわいい https://picdig.net/projects?search_tag=かわいい],
            %w[キャラクターイラスト https://picdig.net/projects?search_tag=キャラクターイラスト],
            %w[キャラクターデザイン https://picdig.net/projects?search_tag=キャラクターデザイン],
            %w[一枚絵 https://picdig.net/projects?search_tag=一枚絵],
            %w[女の子 https://picdig.net/projects?search_tag=女の子],
            %w[秋 https://picdig.net/projects?search_tag=秋],
          ],
        )
      end

      context "A Picdig image URL with a referer" do
        strategy_should_work(
          "https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/42163c7d-16cb-4665-867e-f62b8133359d.png",
          referer: "https://picdig.net/ema/projects/9d99151f-6d3e-4084-9cc0-082d386122ca",
          image_urls: %w[
            https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/42163c7d-16cb-4665-867e-f62b8133359d.png
          ],
          profile_url: "https://picdig.net/ema/portfolio",
          profile_urls: %w[
            https://picdig.net/ema/portfolio
            https://twitter.com/Ema_azure
            https://www.pixiv.net/users/41875383
          ],
          page_url: "https://picdig.net/ema/projects/9d99151f-6d3e-4084-9cc0-082d386122ca",
          display_name: "絵馬",
          username: "ema",
          other_names: ["絵馬", "ema"],
          artist_commentary_title: "「わたしの季節」",
          dtext_artist_commentary_desc: "「わたしの季節」このイラストのコンセプトや構図・配色についてご紹介！イラストコンセプト：''わたしの''秋イラストテーマは秋。秋のキャラクターイラストを思い浮かべるとき多くの人は秋の景色の中にいるキャラクターを連想すると思います。しかしこのイラストは　秋の中にいるわたし　ではなく、「わたしの季節こそが秋なんだ！」そんなメッセージを込めて描いています。あくまで主役はキャラクター。だからこそキャラクターに自然と目線が向かうように構図や配色を考えました。日々勉強中ではありますが、大枠をこんな感じで考えて描いたイラストです(^^)本ページはここまで！お目通しありがとうございましたー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー・ー水色の絵馬キャラクターイラストのお仕事をメインに募集中です。稚拙ではありますが背景付きのイラストも描いております。TwitterやPixivにも多くのイラストを成長の記録として掲載していますので気になる方はぜひご覧下さいね",
          tags: [
            %w[かわいい https://picdig.net/projects?search_tag=かわいい],
            %w[キャラクターイラスト https://picdig.net/projects?search_tag=キャラクターイラスト],
            %w[キャラクターデザイン https://picdig.net/projects?search_tag=キャラクターデザイン],
            %w[一枚絵 https://picdig.net/projects?search_tag=一枚絵],
            %w[女の子 https://picdig.net/projects?search_tag=女の子],
            %w[秋 https://picdig.net/projects?search_tag=秋],
          ],
        )
      end

      context "A Picdig image URL without a referer" do
        strategy_should_work(
          "https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/42163c7d-16cb-4665-867e-f62b8133359d.png",
          image_urls: %w[
            https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/42163c7d-16cb-4665-867e-f62b8133359d.png
          ],
          profile_url: nil,
          profile_urls: [],
          page_url: nil,
          display_name: nil,
          username: nil,
          other_names: [],
          artist_commentary_title: nil,
          artist_commentary_desc: nil,
          tags: []
        )
      end

      should "Parse Picdig URLs correctly" do
        assert(Source::URL.image_url?("https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/7954f986-e471-4d41-9d06-16a1a695b42d.png"))
        assert(Source::URL.image_url?("https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/2022/01/141e8e69-d9cd-46ab-9b9b-62fd8a0d6e7e.png"))
        assert(Source::URL.image_url?("https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2022/04/365f52cb-3007-401e-a762-5452d774210d.png"))
        assert(Source::URL.page_url?("https://picdig.net/ema/projects/9d99151f-6d3e-4084-9cc0-082d386122ca"))
        assert(Source::URL.profile_url?("https://picdig.net/ema/portfolio"))
      end
    end
  end
end
