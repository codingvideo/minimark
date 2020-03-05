require_relative './custom_blog_line'

module MiniMark

  class Parser
    def initialize(filename, _Line=Line)
      @filename = filename
      @_Line = _Line
      @out = nil
    end

    def parse

      return @out.join("\n") if(@out != nil) # caching
      
      file = File.open(@filename)
      lines = file.readlines
      
      @out = []
      scope = nil
      lines.each do |l|
        line = @_Line.new(l, scope)
        @out << line 
        _type = line.line_type
        if _type == :codeopen || _type == :code
          scope = :code
        elsif _type == :listopen || _type == :listitem
          scope = :list
        else
          scope = nil
        end
      end
      file.close

      return @out.join("\n")
    end
  end #class
end #module