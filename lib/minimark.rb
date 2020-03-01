require_relative './renderable'

module MiniMark

  class Line

    include Renderable
      # section_to_s, code_to_s, codeopen_to_s, codeclose_to_s, hint_to_s, html_to_s
      # gonext_to_s, goback_to_s, template_to_s, blank_to_s, paragraph_to_s
    attr :line_type

    def initialize(str, scope=nil)
      @scope = scope

      if(@scope == :code && Util.not_code_scope_close?(str))
        @str = str.rstrip # rstrip only, retain left space
      else
        @str = str.strip 
      end

      custom_type = custom?

      if(custom_type)  ;@line_type = custom_type
      elsif(section?)  ;@line_type = :section
      elsif(code?)     ;@line_type = :code
      elsif(codeopen?) ;@line_type = :codeopen
      elsif(codeclose?);@line_type = :codeclose
      elsif(blank?)    ;@line_type = :blank
      elsif(html?)     ;@line_type = :html
      elsif(template?) ;@line_type = :template
      else             ;@line_type = :paragraph
      end
    end

    def custom?
      if defined?(line_types) != nil
        self.line_types.each do |t|
          if send(t.to_s + '?') == true
            return t # line type is found
          end
        end
        return nil
      else
        return nil
      end
    end

    def section?  ;@str[0]=="#" && @str[1]=="#" && @str[2]!="#" ;end
    def code?     ;@scope == :code && @str != '```' ;end
    def codeopen? ;@str.match(/^```.+/) != nil ;end
    def codeclose?;@scope == :code && @str == '```' ;end
    def blank?    ;@str == '' ;end
    def html?     ;@str[0] == '<' && @str[-1] == '>' ;end
    def template? ;@str[0] == '[' && @str[-1] == ']' ;end

    def to_s
      to_s_method = @line_type.to_s + '_to_s'
      send(to_s_method)
    end
  end #class

  class CustomLine < Line
    
    def line_types
      [ :hint, :gonext, :goback ]
    end

    def hint?   ;@str[0] == '|' ;end
    def gonext? ;@str[0] == '-' && @str[1] == '>'  ;end
    def goback? ;@str[0] == '<' && @str[1] == '-'  ;end

    def hint_to_s
      str = @str.sub(/^\|/, '').strip
      return '<p class="hint">' + str + '</p>'
    end

    def gonext_to_s
      Util.go_link(@str, 'next')
    end

    def goback_to_s
      Util.go_link(@str, 'back')
    end
  end#class

  class Util

    def self.render_template(template_path, data_str)
      data = eval('{' + data_str + '}')
      template = File.read(template_path)
      # 1) swap binding with data
      data.keys.each do |k|
        template = template.gsub(/\{\{\s*#{k.to_s}\s*(\|\|\s*.+\s*)*\}\}/, data[k])
      end
      # 2) for leftovers, use default value
      bindings = template.scan(/\{\{.+\|\s*.+\s*\}\}/)
      bindings.each do |b|
        value_str = b.split(/\s*\|\|\s*/)[1].split(/\s*\}\}/)[0]
        value = eval(value_str)
        template = template.gsub(b, value)
      end
      return template
    end

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
        line = CustomLine.new(l, scope)
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