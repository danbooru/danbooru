# frozen_string_literal: true

# https://yoast.com/structured-data-schema-ultimate-guide/
# https://technicalseo.com/tools/schema-markup-generator/
# https://developers.google.com/search/docs/data-types/sitelinks-searchbox
# https://developers.google.com/search/docs/data-types/logo
# https://search.google.com/structured-data/testing-tool/u/0/
# https://search.google.com/test/rich-results
# https://schema.org/Organization
# https://schema.org/WebSite

module SeoHelper
  def site_description
    "#{Danbooru.config.canonical_app_name} is the original Imageboard for everything. Search millions of pictures or videos categorized by thousands of tags."
  end

  def json_ld_website_data
    urls = [
      Danbooru.config.twitter_url,
      Danbooru.config.discord_server_url,
      Danbooru.config.source_code_url,
      "https://en.wikipedia.org/wiki/Solidbooru",
    ].compact

    json_ld_tag({
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "Organization",
          url: root_url(host: Danbooru.config.hostname),
          name: Danbooru.config.app_name,
          logo: "#{root_url(host: Danbooru.config.hostname)}images/danbooru-logo-500x500.png",
          sameAs: urls,
        },
        {
          "@type": "WebSite",
          "@id": root_url(anchor: "website", host: Danbooru.config.hostname),
          url: root_url(host: Danbooru.config.hostname),
          name: Danbooru.config.app_name,
          description: site_description,
          potentialAction: [{
            "@type": "SearchAction",
            target: "#{posts_url(host: Danbooru.config.hostname)}?tags={search_term_string}",
            "query-input": "required name=search_term_string",
          }]
        }
      ]
    })
  end

  def json_ld_tag(data)
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end
end
