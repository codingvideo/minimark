module MiniMark
  class Line

    attr :line_type

    def initialize(str, scope=nil)
      @scope = scope

      if @scope == :code  && str.strip != '```'
        @str = str.rstrip + ' ' # rstrip only, retain left space
      else
        @str = str.strip 
      end

      if(heading?)
        @line_type = :heading
      elsif(section?)
        @line_type = :section
      elsif(code?)
        @line_type = :code
      elsif(codeopen?)
        @line_type = :codeopen
      elsif(codeclose?)
        @line_type = :codeclose
      elsif(blank?)
        @line_type = :blank
      else
        @line_type = :paragraph
      end
    end

    def heading?
      @str[0]=="#" && @str[1]!="#"
    end

    def section?      
      @str[0]=="#" && @str[1]=="#" && @str[2]!="#"
    end

    def code?
      @scope == :code && @str != '```'
    end

    def codeopen?
      str = @str.strip
      str.match(/^```.+/) != nil
    end

    def codeclose?
      @scope == :code && @str == '```'
    end

    def blank?
      @str == ''
    end

    def to_s
      if(@line_type == :heading)
        str = @str.sub(/^#/, '').strip
        str =  str.sub('[', '<span class="boxed">')
        str =  str.sub(']', '</span>')
        return '<h1>' + str + '</h1>'
      elsif(@line_type == :section)
        str = @str.sub(/^##/, '').strip
        return '<h2>' + str + '</h2>'
      elsif(@line_type == :code)
        return replace_brackets(/___/, 'light')
      elsif(@line_type == :codeopen)
        lang = @str.sub('```','').strip
        return '<pre class="prettyprint lang-'+lang+'">'
      elsif(@line_type == :codeclose)
        return '</pre>'
      elsif(@line_type == :paragraph)
        str = replace_brackets(/`/, 'mono')
        return '<p>' + str + '</p>'
      else # @line_type == :blank
        return ""
      end
    end

    def replace_brackets(bracket, span_class)
      bracket_count = @str.scan(bracket).size
      highlighted = bracket_count > 0 && bracket_count % 2 == 0
      if(highlighted)
        segments = (@str+' ').split(bracket)
        str = ''
        bit = true
        segments.each_with_index do |s, i|
          str += s
          if(i != segments.size-1) # not last
            if(bit) # open tag
              str += '<span class="'+span_class+'">' 
            else # close tag
              str += '</span>'
            end
            bit = !bit # flip the bit
          end
        end
        return str
      else
        return @str
      end
    end
  end #class

  class Parser
    def initialize(filename)
      @filename = filename
      @out = nil
    end

    def parse
      return @out.join("\n") if(@out != nil)
      
      file = File.open(@filename)
      lines = file.readlines
      
      @out = []
      scope = nil
      lines.each do |l|
        line = Line.new(l, scope)
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