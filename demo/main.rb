require 'minimark'

parser = MiniMark::Parser.new('test.md')
html = parser.parse
File.write('test.html', '<html><body>'+html+'</body></html>')
