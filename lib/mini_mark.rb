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
        if line.line_type == :codeopen
          scope = :code
        elsif line.line_type == :code
          scope = :code
        elsif line.line_type == :codeclose
          scope = nil
        elsif line.line_type == :listopen
          scope = :list
        elsif line.line_type == :listitem
          scope = :list
        elsif line.line_type == :listclose
          scope = nil
        end
      end
      file.close

      return @out.join("\n")
    end
  end #class
end #module