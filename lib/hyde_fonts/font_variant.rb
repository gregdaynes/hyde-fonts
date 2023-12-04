module Hyde
  class FontVariant
    attr_reader :italic, :weight

    def initialize(weight:, italic:)
      @weight = weight
      @italic = 0

      if italic == true
        @italic = 1
      end
    end

    def to_s
      @italic.to_s + ',' + @weight.to_s
    end
  end
end
