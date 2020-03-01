require_relative './custom_blog_line'

module MiniMark

  class Parser
    def initialize(filename, _CustomLine)
      @filename = filename
      @_CustomLine = _CustomLine
      @out = nil
    end

    def parse

      return @out.join("\n") if(@out != nil) # caching
      
      file = File.open(@filename)
      lines = file.readlines
      
      @out = []
      scope = nil
      lines.each do |l|
        line = @_CustomLine.new(l, scope)
        @out << line 
        if line.line_type == :codeopen
          scope = :code
        elsif line.line_type == :code
          scope = :code
        elsif line.line_type == :codeclose
          scope = nil
        end
      end
      file.close

      return @out.join("\n")
    end
  end #class
end #module