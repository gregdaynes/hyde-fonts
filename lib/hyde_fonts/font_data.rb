module Hyde
  class FontData
    attr_reader :faces

    def initialize(data)
      @data = data
      @faces = []
      @sizes = []

      return unless @data

      parse_faces
    end

    def parse_faces

      for face in @data['faces'] do
        faces.push(Hyde::FontFace.new(face))
      end

      return faces
    end
  end
end
