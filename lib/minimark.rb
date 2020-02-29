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
      elsif(hint?)
        @line_type = :hint
      elsif(blank?)
        @line_type = :blank
      elsif(html?)
        @line_type = :html
      elsif(gonext?)
        @line_type = :gonext
      elsif(goback?)
        @line_type = :goback
      elsif(template?)
        @line_type = :template
      else
        @line_type = :paragraph
      end
    end

    def heading?
      @str[0]=="#" && @str[1]!= "#"
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

    def hint?
      @str[0] == '|'
    end

    def blank?
      @str == ''
    end

    def html?
      @str[0] == '<' && @str[-1] == '>'
    end

    def gonext?
      @str[0] == '-' && @str[1] == '>'
    end

    def goback?
      @str[0] == '<' && @str[1] == '-'
    end

    def template?
      @str[0] == '[' && @str[-1] == ']'
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
        if(lang=='cmd')
          return '<pre class="cmd">'
        else
          return '<pre class="prettyprint lang-'+lang+'">'
        end
      elsif(@line_type == :codeclose)
        return '</pre>'
      elsif(@line_type == :hint)
        str = @str.sub(/^\|/, '').strip
        return '<p class="hint">' + str + '</p>'
      elsif(@line_type == :html)
        return @str
      elsif(@line_type == :gonext)
        return go_link(@str, 'next')
      elsif(@line_type == :goback)
        return go_link(@str, 'back')
      elsif(@line_type == :template)
        template_path = @str.gsub(/\[|\]/, '').strip
        return File.read(template_path)
      elsif(@line_type == :paragraph)
        str = replace_brackets(/`/, 'mono')
        str = str.sub(/^\^\s/, '&uarr; ')
        str = str.sub(/^v\s/, '&darr; ')
        return '<p>' + str + '</p>'
      else # @line_type == :blank
        return ""
      end
    end

    def go_link(str, _class)
      parts = str.split(/\(|\)/)
      '<div class="go-box '+_class+'">' +
        '<a class="go '+_class+'" href="'+parts[1].strip+'">' +
          (_class=='back' ? '&larr; ' : '') +
          parts[2].strip + 
          (_class=='next' ? ' &rarr;' : '') +
        '</a>' +
      '</div>'
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