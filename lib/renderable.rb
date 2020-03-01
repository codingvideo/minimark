require_relative './util'

module MiniMark

  module Renderable

    def code_to_s
      return MiniMark::Util.replace_brackets(@str, /___/, 'light')
    end

    def codeopen_to_s
      lang = @str.sub('```','').strip
      if(lang=='cmd')
        return '<pre class="cmd">'
      else
        return '<pre class="prettyprint lang-'+lang+'">'
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
        return MiniMark::Util.render_template(template_path, data_str)
      else
        return File.read(template_path)
      end
    end

    def blank_to_s
      return ""
    end

    def paragraph_to_s
      str = MiniMark::Util.replace_brackets(@str, /`/, 'mono')
      str = str.sub(/^\^\s/, '&uarr; ')
      str = str.sub(/^v\s/, '&darr; ')
      return '<p>' + str + '</p>'
    end
  end#module
end#module