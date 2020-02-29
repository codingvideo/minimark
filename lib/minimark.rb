module MiniMark
  
  class Line

    attr :line_type

    def initialize(str, scope=nil)
      @scope = scope

      if(@scope == :code && Util.not_code_scope_close?(str))
        @str = str.rstrip + ' ' # rstrip only, retain left space
      else
        @str = str.strip 
      end

      if(heading?)     ;@line_type = :heading
      elsif(section?)  ;@line_type = :section
      elsif(code?)     ;@line_type = :code
      elsif(codeopen?) ;@line_type = :codeopen
      elsif(codeclose?);@line_type = :codeclose
      elsif(hint?)     ;@line_type = :hint
      elsif(blank?)    ;@line_type = :blank
      elsif(html?)     ;@line_type = :html
      elsif(gonext?)   ;@line_type = :gonext
      elsif(goback?)   ;@line_type = :goback
      elsif(template?) ;@line_type = :template
      else             ;@line_type = :paragraph
      end
    end

    def heading?  ;@str[0]=="#" && @str[1]!= "#" ;end
    def section?  ;@str[0]=="#" && @str[1]=="#" && @str[2]!="#" ;end
    def code?     ;@scope == :code && @str != '```' ;end
    def codeopen? ;@str.match(/^```.+/) != nil ;end
    def codeclose?;@scope == :code && @str == '```' ;end
    def hint?     ;@str[0] == '|' ;end
    def blank?    ;@str == '' ;end
    def html?     ;@str[0] == '<' && @str[-1] == '>' ;end
    def gonext?   ;@str[0] == '-' && @str[1] == '>'  ;end
    def goback?   ;@str[0] == '<' && @str[1] == '-'  ;end
    def template? ;@str[0] == '[' && @str[-1] == ']' ;end

    def to_s

      if(:heading == @line_type)
        str = @str.sub(/^#/, '').strip
        str =  str.sub('[', '<span class="boxed">')
        str =  str.sub(']', '</span>')
        return '<h1>' + str + '</h1>'

      elsif(:section == @line_type)
        str = @str.sub(/^##/, '').strip
        return '<h2>' + str + '</h2>'

      elsif(:code == @line_type)
        return Util.replace_brackets(@str, /___/, 'light')

      elsif(:codeopen == @line_type)
        lang = @str.sub('```','').strip
        if(lang=='cmd')
          return '<pre class="cmd">'
        else
          return '<pre class="prettyprint lang-'+lang+'">'
        end

      elsif(:codeclose == @line_type)
        return '</pre>'

      elsif(:hint == @line_type)
        str = @str.sub(/^\|/, '').strip
        return '<p class="hint">' + str + '</p>'

      elsif(:html == @line_type)
        return @str

      elsif(:gonext == @line_type)
        return Util.go_link(@str, 'next')

      elsif(:goback == @line_type)
        return Util.go_link(@str, 'back')

      elsif(:template == @line_type)
        template_path = @str.gsub(/\[|\]/, '').strip
        return File.read(template_path)

      elsif(:blank == @line_type)
        return ""

      else # :paragraph
        str = Util.replace_brackets(@str, /`/, 'mono')
        str = str.sub(/^\^\s/, '&uarr; ')
        str = str.sub(/^v\s/, '&darr; ')
        return '<p>' + str + '</p>'
      end
    end#def
  end #class

  class Util

    def self.not_code_scope_close?(str)
      str.strip != '```'
    end

    def self.go_link(str, _class)
      parts = str.split(/\(|\)/)
      '<div class="go-box '+_class+'">' +
        '<a class="go '+_class+'" href="'+parts[1].strip+'">' +
          (_class=='back' ? '&larr; ' : '') +
          parts[2].strip + 
          (_class=='next' ? ' &rarr;' : '') +
        '</a>' +
      '</div>'
    end

    def self.replace_brackets(str, bracket, span_class)
      bracket_count = str.scan(bracket).size
      highlighted = bracket_count > 0 && bracket_count % 2 == 0
      if(highlighted)
        segments = (str+' ').split(bracket)
        out = ''
        bit = true
        segments.each_with_index do |s, i|
          out += s
          if(i != segments.size-1) # not last
            if(bit) # open tag
              out += '<span class="'+span_class+'">' 
            else # close tag
              out += '</span>'
            end
            bit = !bit # flip the bit
          end
        end
        return out
      else
        return str
      end
    end
  end#class

  class Parser
    def initialize(filename)
      @filename = filename
      @out = nil
    end

    def parse
      
      return @out.join("\n") if(@out != nil) # caching
      
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