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
  def json_ld_website_data
    site_url = Danbooru.config.canonical_url.chomp("/")

    urls = [
      Danbooru.config.twitter_url,
      Danbooru.config.discord_server_url,
      Danbooru.config.source_code_url,
      "https://en.wikipedia.org/wiki/Danbooru",
    ].compact

    json_ld_tag({
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "Organization",
          url: site_url,
          name: Danbooru.config.app_name,
          logo: "#{site_url}/images/danbooru-logo-500x500.png",
          sameAs: urls,
        },
        {
          "@type": "WebSite",
          "@id": "#{site_url}/#website",
          url: site_url,
          name: Danbooru.config.app_name,
          description: Danbooru.config.site_description,
          potentialAction: [{
            "@type": "SearchAction",
            target: "#{site_url}/posts?tags={search_term_string}",
            "query-input": "required name=search_term_string",
          }]
        }.compact
      ]
    })
  end

  def json_ld_tag(data)
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end
end
