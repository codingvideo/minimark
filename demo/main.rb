require 'mini_mark/parser'
require 'mini_mark/custom_blog_line'

parser = MiniMark::Parser.new('test.md', MiniMark::CustomBlogLine)
html = parser.parse
File.write('test.html', '<html><body>'+html+'</body></html>')
