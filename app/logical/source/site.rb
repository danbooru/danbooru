# frozen_string_literal: true

# A Source::Site represents a site handled by an URL parser or extractor. All URL parsers use the `site` macro to
# declare which site(s) they handle, like this:
#
#     site "Pixiv", url: "https://www.pixiv.net", domains: %w[pixiv.net pximg.net]
#
# Sites have a name, a URL (used to link to the site's homepage), a list of domains (used to match domains to sites), a
# stable numeric ID (used to store site IDs in the database), an internal name (used to generate the numeric ID, so that
# it stays the same in case the site's name ever changes), and a list of options and credentials.
module Source
  class Site
    # @return [Hash<Symbol, OptionDefinition>] A mapping of option names to definitions. The definition describes the option's type, default value, help string, etc.
    attr_accessor :options

    # @return [Source::URL] The Source::URL subclass that handles this site.
    attr_accessor :url_class

    # @return [Array<Site>] A list of all sites handled by URL classes.
    def self.sites
      @sites ||= Source::URL.url_subclasses.flat_map(&:sites)
    end

    # @return [Hash<String, Site>] A mapping of site names (e.g. "Twitter", "Pixiv", etc) to sites.
    def self.sites_by_name
      @sites_by_name ||= sites.index_by(&:name)
    end

    # @return [Hash<String, Array<Site>>] A mapping of domain names (e.g. "twitter.com", "pximg.net", etc) to the list of sites using that domain.
    def self.sites_by_domain
      @sites_by_domain ||=
        sites.flat_map { |site| site.domains.map { |domain| [domain, site] } }
             .group_by(&:first)
             .transform_values { |pairs| pairs.map(&:last) }
    end

    # @return [Site, nil] The site with the given name, or nil if no such site exists.
    def self.find(name)
      sites_by_name[name]
    end

    # @return [Array<Site>] The list of sites belonging to the given domain, or an empty array if none have that domain.
    def self.find_by_domain(domain)
      sites_by_domain[domain].to_a
    end

    # @param name [String] The name of this site, e.g. "Pixiv", "Twitter". If a site's name changes, the `internal_name`
    #   should be set to the old name to keep site IDs stable.
    # @param internal_name [String] A stable string ID for this site, e.g. "pixiv", "twitter". Once a site's internal
    #   name is chosen, it should never be changed, as it's used to generate the site's numeric ID.
    # @param url [String] The primary URL for the site, e.g. "https://www.pixiv.net", "https://x.com".
    # @param domains [Array<String>] A list of domains that belong to this site, e.g. ["pixiv.net", "pximg.net"].
    #   Different sites may use the same domain (e.g. multiple sites using the same CDN). This doesn't have to include
    #   every domain (e.g. Google has too many country code domains to list), but if multiple sites use the same domain,
    #   it should be listed on all of them. If not set, the domain is taken from the `url`.
    # @param url_class [Source::URL] The Source::URL subclass that handles this site.
    # @yieldparam [Site] The block is evaluated in the context of the new site, allowing you to set properties with e.g. `Site.new { name "Pixiv" }`
    def initialize(name: nil, internal_name: nil, url: nil, domains: [], url_class: nil, &block)
      self.name = name
      self.internal_name ||= internal_name
      self.url = url
      self.domains = domains.presence || [@url&.domain].compact
      self.url_class = url_class
      self.options = {}.with_indifferent_access

      instance_eval(&block) if block_given?
    end

    # @return [Array<Source::Extractor>] The list of extractors that can be used by this site.
    def extractors
      url_class.extractors
    end

    # @return [Integer] A stable 32-bit numeric ID for this site.
    def site_id
      @site_id ||= Digest::SHA256.digest(internal_name).unpack1("V") # V = 32-bit little-endian
    end

    # @param name [String] The site's name.
    def name=(name)
      @name = name
      self.internal_name ||= name
    end

    # @param name [String] The site's internal name. Once chosen, should never be changed.
    def internal_name=(name)
      @internal_name = name&.downcase&.gsub(/[^a-z0-9.-]+/, "-")&.squeeze("-")
      @site_id = nil
    end

    # @param url [String] The site's primary URL.
    def url=(url)
      @url = Danbooru::URL.parse!(url) if url.present?
    end

    # @param domains [Array<String>] A list of domains that belong to the site.
    def domains=(domains)
      @domains = domains.to_set
    end

    # Get the value if no argument is given, or set the value if given an argument.
    def name(*value) = value.empty? ? @name : self.name = value.sole
    def internal_name(*value) = value.empty? ? @internal_name : self.internal_name = value.sole
    def url(*value) = value.empty? ? @url : self.url = value.sole
    def domains(*value) = value.empty? ? @domains : self.domains = value.sole

    # Define a new option for this site.
    #
    # @param name [String, nil] The name of the option.
    # @param params [Hash<Symbol, Object>] The parameters for the option.
    def option(name = nil, **params)
      @options[name] = OptionDefinition.new(self, name, **params)
    end

    # Define a credential (password, session cookie, etc) for this site.
    def credential(*args, **params, &block)
      option(*args, **params, kind: :credential, &block)
    end

    # A class for defining an option or credential used by a site. Option definitions have a name, type (string,
    # boolean, etc), default value, a help string, and a kind (whether they're a normal setting or a credential).
    class OptionDefinition
      attr_reader :site

      # @param site [Site] The site this option belongs to.
      # @param name [String, Symbol] The name of the option.
      # @param type [Symbol] The option's type (:string, :boolean, etc).
      # @param default [Object] The default value for the option.
      # @param kind [Symbol] The kind of option (:setting or :credential)
      # @param help [String] A help string describing the option.
      # @yieldparam [Option] The block is evaluated in the context of the option, allowing you to set properties with e.g `option { type :boolean }`
      def initialize(site, name, type: :string, default: nil, kind: :setting, help: nil, &block)
        @site = site
        @name = name.to_sym
        @type = type || :string
        @default = default
        @kind = kind
        @help = help

        instance_eval(&block) if block_given?
      end

      # Get the value if no argument is given, or set the value if given an argument.
      def name(*value) = value.empty? ? @name : self.name = value.sole
      def type(*value) = value.empty? ? @type : self.type = value.sole
      def default(*value) = value.empty? ? @default : self.default = value.sole
      def kind(*value) = value.empty? ? @kind : self.kind = value.sole
      def help(*value) = value.empty? ? @help : self.help = value.sole
    end

    # A class for storing the actual value of an option. Extractors are given a list of these options.
    class Option
      attr_reader :definition, :value

      def initialize(definition, value = nil)
        @definition = definition
        @value = value || definition.default
      end
    end
  end
end
