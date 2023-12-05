require 'uri'
require 'net/http'

module Hyde
  class FontProviderGoogle
    def initialize(site, config)
      @site = site
      @config = config
    end

    def fetch(face)
      @face = face

      begin
        uri_payload = Net::HTTP.get(face_uri, {
          "User-Agent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/117.0'
        })
      rescue
        Jekyll.logger.warn('Fonts Warning:', 'Unable to reach Google Fonts service.')
        return
      end

      rulesets = parse_css_payload(uri_payload)

      # TODO if @config['fetch_fonts'] is false, don't download the files

      for ruleset in rulesets
        fetch_font_from_ruleset(ruleset)
        face.css.push(rewrite_ruleset_to_local(ruleset))
      end
    end

  private

    def face_uri
      google_uri_base = 'https://fonts.googleapis.com/css2'
      params = [['display', 'swap']]
      params.push(['family', @face.to_s])

      uri = google_uri_base + '?' + params.map { |param| param.join('=') }.join('&')

      URI(uri)
    end

    def parse_css_payload(css)
      css.scan(/\/\*[^}]*}/).map do |raw_ruleset|
        Hyde::FontRuleset.new(raw_ruleset)
      end
    end

    def fetch_font_from_ruleset(ruleset)
      filename = ruleset.filename
      file = Hyde::GeneratedFontFile.new(@site, @config['file_output_path'], filename)

      destination_fname = file.destination('./')

      if @config['keep_files'] == true
        Jekyll.logger.debug('Fonts:', "file #{filename} already exists.")
        return if File.exist?(destination_fname)
      end

      if @config['fetch_fonts'] == false
        Jekyll.logger.warn('Fonts:', "fetch disabled, no local version of #{filename} found.")
        return
      end

      Jekyll.logger.debug('Fonts:', "downloading #{@face.name} from #{@face.provider}")
      font_uri_payload = Net::HTTP.get(ruleset.uri)
      file.file_contents = font_uri_payload

      @site.static_files << file
    end

    def rewrite_ruleset_to_local(ruleset)
      ruleset.local_ruleset(@config['file_output_path'])
    end
  end
end
