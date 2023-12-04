require 'jekyll'
require_relative 'font_data.rb'
require_relative 'font_face.rb'
require_relative 'font_ruleset.rb'
require_relative 'font_variant.rb'
require_relative 'generated_css_file.rb'
require_relative 'generated_font_file.rb'
require_relative 'provider_google.rb'

module Jekyll
  class HydeFontsTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super

      @tag_name = tag_name
      @text = text.strip
      @tokens = tokens
    end

    def render(context)
      config = context.registers[:site].config['hyde_fonts']
      return unless config['enable'] == true

      file = context.registers[:site].static_files.find { |file|
        file.is_a?(Hyde::GeneratedCssFile)
      }

      if @text == 'inline'
        file.file_contents
      else
        "<link href='" + file.relative_path + "' rel='stylesheet'>"
      end
    end
  end

  Liquid::Template.register_tag('hyde_fonts', Jekyll::HydeFontsTag)

  class HydeFontsGenerator < Generator
    def generate(site)
      Hyde::Fonts.new(site).generate()
    end
  end
end

module Hyde
  class Fonts
    @@config = {
      "data_path" => 'fonts',
      "file_output_path" => 'assets/fonts',
      "css_output_name" => 'fonts.css',
      "css_minify" => true,
      "enable" => true,
      "fetch_fonts" => true,
      "keep_files" => false
    }

    def initialize(site)
      @site = site
      @config = site.config.dig('hyde_fonts') || @@config

      if config('keep_files') == true
        @site.config['keep_files'].push(config('file_output_path'))
      end

      if site.config.dig('hyde_fonts').nil?
        @site.config['hyde_fonts'] = @config
      end
    end

    def generate
      # get faces from jekyll data file
      font_data = Hyde::FontData.new(data)

      # handle font providers
      for face in font_data.faces
        case face.provider
        when 'google'
          Hyde::FontProviderGoogle.new(@site, @config).fetch(face)
        when 'local'
          # TODO handle local fonts
          # Hyde::FontProviderLocal.new(@site, @config).fetch(face)
        end
      end

      css = font_data.faces.map { |face| face.css }
      # generate static file containing face css rulesets
      css_file = Hyde::GeneratedCssFile.new(@site, config('file_output_path'), config('css_output_name'))
      css_file.file_contents = minify(css.join("\n"))

      @site.static_files << css_file
    end

  private

    def config(*keys)
      @config.dig(*keys)
    end

    def data
      @site.data.dig(config('data_path'), 'fonts')
    end

    def minify(css)
      return css if config('css_minify') == false

      converter_config = { 'sass' => { 'style' => 'compressed' } }

      Jekyll::Converters::Scss.new(converter_config).convert(css)
    end
  end
end
