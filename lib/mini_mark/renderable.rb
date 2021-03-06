require_relative './util'

module MiniMark

  module Renderable

    def listitem_to_s
      str = @str.sub(/^\-\s/, '')
      str = Util.replace_brackets(str, /`/, 'mono')
      return "<li>" + str + "</li>"
    end

    def listopen_to_s
      return '<ul>' + listitem_to_s # first item as open
    end

    def listclose_to_s
      return '</ul>'
    end

    def code_to_s
      return @str.gsub('<', '&lt;').gsub('>', '&gt;')
    end

    def codeopen_to_s
      lang = @str.sub('```','').strip
      if(lang=='cmd')
        return '<pre class="cmd">'
      else
        return '<pre class="'+syntax_highlighter_class(lang)+'">'
      end
    end

    def codeclose_to_s
      return '</pre>'
    end

    def html_to_s
      return @str
    end

    def template_to_s
      template_spec = @str.gsub(/^\[|\]$/, '').strip.split('|', 2)
      template_path = template_spec[0].strip
      data_str = template_spec[1] # for eval
      if(template_spec.size >= 2)
        return Util.render_template(template_path, data_str)
      else
        return File.read(template_path)
      end
    end

    def blank_to_s
      return ""
    end

    def paragraph_to_s
      str = Util.replace_brackets(@str, /`/, 'mono')
      str = str.sub(/^\^\s/, '&uarr; ')
      str = str.sub(/^v\s/, '&darr; ')
      return '<p>' + str + '</p>'
    end

    # default
    def syntax_highlight_class(lang)
      'code '+lang
    end
  end#module
end#module
