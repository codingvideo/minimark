require_relative './util.rb'
require_relative './renderable'

module MiniMark

  class Line

    include Renderable
    
    attr :line_type

    def initialize(str, scope=nil)
      @scope = scope # :code | :list

      if(@scope == :code && Util.not_code_scope_close?(str))
        @str = str.rstrip # rstrip only, retain left space
      else
        @str = str.strip 
      end

      custom_type = custom?

      if(custom_type)  ;@line_type = custom_type
      elsif(listitem?) ;@line_type = :listitem
      elsif(listopen?) ;@line_type = :listopen
      elsif(listclose?);@line_type = :listclose
      elsif(code?)     ;@line_type = :code
      elsif(codeopen?) ;@line_type = :codeopen
      elsif(codeclose?);@line_type = :codeclose
      elsif(blank?)    ;@line_type = :blank
      elsif(html?)     ;@line_type = :html
      elsif(template?) ;@line_type = :template
      else             ;@line_type = :paragraph
      end
    end#def

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

    def listitem? ;@scope == :list && @str != '' ;end
    def listopen? ;@str.match(/^\-\s/) != nil && @scope == nil ;end
    def listclose?;@scope == :list && @str.match(/^\-\s/) == nil ;end
    def code?     ;@scope == :code && @str != '```' ;end
    def codeopen? ;@str.match(/^```.+/) != nil && @scope == nil ;end
    def codeclose?;@scope == :code && @str == '```' ;end
    def blank?    ;@str == '' ;end
    def html?     ;@str[0] == '<' && @str[-1] == '>' ;end
    def template? ;@str[0] == '[' && @str[-1] == ']' ;end

    def to_s
      to_s_method = @line_type.to_s + '_to_s'
      send(to_s_method)
    end
  end#class
end#module