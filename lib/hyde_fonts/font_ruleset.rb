module Hyde
  class FontRuleset
    attr_reader :filename, :char_set, :family, :style, :weight, :uri, :format, :ruleset, :local_rule_set

    def initialize(raw_css_ruleset)
      @ruleset = raw_css_ruleset

      /\/\* (?'character_set'.*) \*\// =~ raw_css_ruleset
      /^\s*font-family:\s'(?'family'[\w]*)';$/ =~ raw_css_ruleset
      /^\s*font-style:\s(?'style'[\w]*);$/ =~ raw_css_ruleset
      /^\s*font-weight:\s(?'weight'[\w]*);$/ =~ raw_css_ruleset
      /\s\ssrc:\surl\((?'uri'.*)\)\s.*\('(?'format'.*)'\);$$/ =~ raw_css_ruleset

      @char_set = character_set
      @family = family
      @style = style
      @weight = weight
      @uri = URI(uri)
      @format = format

      @filename = [@family, @style, @weight, @char_set + "." + @format].join("_")
    end

    def local_ruleset(path)
      @ruleset.gsub(/(?<=url\().*(?=\)\s)/, "/" + File.join(path, @filename))
    end
  end
end
