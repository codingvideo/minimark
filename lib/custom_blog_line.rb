require_relative './line'
require_relative './util'

module MiniMark

  class CustomBlogLine < MiniMark::Line
    
    def line_types
      [ :hint, :gonext, :goback, :section, :litcode ]
    end

    def hint?   ;@str[0] == '|' ;end
    def gonext? ;@str[0] == '-' && @str[1] == '>'  ;end
    def goback? ;@str[0] == '<' && @str[1] == '-'  ;end
    def section?;@str[0] == "#" && @str[1]=="#" && @str[2]!="#" ;end
    def litcode?;@scope == :code && @str != '```' && @str.scan('___').size > 1 ;end

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

    def section_to_s
      str = @str.sub(/^##/, '').strip
      return '<h2>' + str + '</h2>'
    end

    def litcode_to_s
      Util.replace_brackets(@str, /___/, 'light')
    end
  end#class
end#module