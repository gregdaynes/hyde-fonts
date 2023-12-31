require "jekyll"
require_relative "font_data"
require_relative "font_face"
require_relative "font_ruleset"
require_relative "font_variant"
require_relative "generated_css_file"
require_relative "generated_font_file"
require_relative "provider_google"

module Jekyll
  class HydeFontsTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super

      @tag_name = tag_name
      style, indent = text.strip.split(" ")
      return if style.nil?
      @style = style.strip
      @indent = indent.to_i || 0
      @tokens = tokens
    end

    def render(context)
      return unless context.registers[:site].config.dig("hyde_fonts", "enable") == true

      file = context.registers[:site].static_files.find { |file|
        file.is_a?(Hyde::GeneratedCssFile)
      }

      if @style == "inline"
        file.file_contents
      elsif @style == "link"
        "<link href='/" + context.registers[:site].config['baseurl'] + file.path + "' rel='stylesheet'>"
      elsif @style == "decap-config"
        [
          "- label: Hyde-Fonts",
          "  name: fonts",
          "  file: \"src/_data/fonts.yml\"",
          "  fields:",
          "    - label: Fonts",
          "      name: fonts",
          "      widget: object",
          "      fields:",
          "        - label: Faces",
          "          name: faces",
          "          widget: list",
          "          collapsed: false",
          "          create: true",
          "          fields:",
          "            - label: Name",
          "              name: name",
          "              widget: string",
          "            - label: Weights",
          "              name: weights",
          "              widget: list",
          "              collapsed: false",
          "              fields:",
          "                - label: Weight",
          "                  name: value",
          "                  widget: string",
          "                - label: Italic",
          "                  name: italic",
          "                  widget: boolean"
        ]
          .map { |x| x.prepend(" " * 6) }
          .join("\n")
          .prepend("# Hyde Fonts ---\n")
      end
    end
  end

  Liquid::Template.register_tag("hyde_fonts", Jekyll::HydeFontsTag)

  class HydeFontsGenerator < Generator
    def generate(site)
      Hyde::Fonts.new(site).generate
    end
  end
end

module Hyde
  class Fonts
    @@config = {
      "data_source_name" => "fonts",
      "file_output_path" => "assets/fonts",
      "css_output_name" => "fonts.css",
      "css_minify" => true,
      "enable" => true,
      "fetch_fonts" => true,
      "keep_files" => true
    }

    def initialize(site)
      @site = site
      @config = site.config.dig("hyde_fonts")

      if @config.nil?
        @config = @@config
        site.config["hyde_fonts"] = @config
      end

      if config("keep_files") == true
        @site.config["keep_files"].push(config("file_output_path"))
      end

      if site.config.dig("hyde_fonts").nil?
        @site.config["hyde_fonts"] = @config
      end
    end

    def generate
      return unless config("enable") == true
      # get faces from jekyll data file
      font_data = Hyde::FontData.new(data)

      # handle font providers
      for face in font_data.faces
        Jekyll.logger.info("Fonts:", "Preparing #{face.name}")

        case face.provider
        when "google"
          Hyde::FontProviderGoogle.new(@site, @config).fetch(face)
        when "local"
          # TODO handle local fonts
          # Hyde::FontProviderLocal.new(@site, @config).fetch(face)
        end
      end

      css = font_data.faces.map { |face| face.css }
      # generate static file containing face css rulesets
      css_file = Hyde::GeneratedCssFile.new(@site, config("file_output_path"), config("css_output_name"))
      css_file.file_contents = minify(css.join("\n"))

      @site.static_files << css_file
    end

    private

    def config(*)
      @config.dig(*)
    end

    def data
      @site.data.dig(config("data_source_name"), "fonts")
    end

    def minify(css)
      return css if config("css_minify") == false

      converter_config = {"sass" => {"style" => "compressed"}}

      Jekyll::Converters::Scss.new(converter_config).convert(css)
    end
  end
end
