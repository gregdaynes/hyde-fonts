module Hyde
  class FontFace
    attr_reader :provider, :name
    attr_accessor :css

    def initialize(face)
      @name = face['name']
      @provider = face['provider']
      @weights = face['weights']
      @variants = parse_variants
      @css = []
    end

    def sort_variants
      @variants.sort do |a, b|
        (a.italic == b.italic) ? a.weight <=> b.weight : a.italic <=> b.italic
      end
    end

    def to_s
      variants = sort_variants.map { |variant| variant.to_s }

      @name + ':ital,wght@' + variants.join(';')
    end

  private

    def parse_variants
      variants = []

      for variant in @weights
        variants.push(Hyde::FontVariant.new(weight: variant['value'], italic: variant['italic']))
      end

      return variants
    end
  end
end
