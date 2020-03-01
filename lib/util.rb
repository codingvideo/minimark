module MiniMark

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
end #module