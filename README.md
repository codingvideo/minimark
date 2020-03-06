# MiniMark - Extensible Markdown Parser

## Getting Started

1. Clone the project:
```bash
$ git clone https://github.com/codingvideo/minimark.git
```

2. Install the gem:
```bash
$ gem install minimark/minimark-0.0.1.gem
```

3. Remove the project:
```bash
$ rm -rf minimark
```

## API

`MiniMark::Parser` is the main front-facing class. The constructor takes the address to your markdown file, and you can use the `parse` method to compile and get back the resulting HTML.

```rb
require 'mini_mark/parser'

parser = MiniMark::Parser.new('hello.md')
html = parser.parse
File.write('hello.html', html)
```

The constructor has a second optional parameter. This should be a `Line` subclass or the `Line` class itself, by default, it's the `Line` class.

The `Line` class controls the kind of content to parse for each line, it's meant to be subclassed by your own custom class. By default the `Line` class will parse the following line types:

- List
- Plain HTML
- Template Include e.g. `[header.html | title: "Page Title"]`
- Code Embed (checkout the demo for syntax)
- Paragraph (if nothing else is matched)

The `CustomBlogLine` that comes with the gem is a subclass of `Line` that gets extended with a few additional line types:

- Go-Back Button
- Go-Next Button
- Code Embed that can highlight certain parts of the code
- Section Heading

You can import the `CustomBlogLine` class from `mini_mark/custom_blog_line`:

```rb
require 'mini_mark/parser'
require 'mini_mark/custom_blog_line'

parser = MiniMark::Parser.new('hello.md', MiniMark::CustomBlogLine)
html = parser.parse
File.write('hello.html', html)
```

Check out the demo for the exact syntax and HTML output for each line type.

## Custom Line

This section will go into detail about how to create your own `Line` subclass.

The goal of subclassing the `Line` class is to create additional line types specifically for your project.

First, inherit the `Line` class.

```rb
class CustomLine < MiniMark::Line

end
```

We'll implement a new line type called `:hint`. Each line type name is represented by a symbol object.

There are three requirements for each line type.

1) Return the name in an array from a method called `line_types`.

```rb
  class CustomLine < MiniMark::Line

    def line_types
      [ :hint ]
    end
  end
```

2) A method that returns a boolean, and named after the line type suffixed with a question mark.

```rb

  class CustomLine < MiniMark::Line

    def line_types
      [ :hint ]
    end
    
    def hint? 
      @str[0] == '|'
    end
  ...
```

This question mark method is for checking whether a line should be of a particular type. In this case, a line is considered a hint type if the first character of the string is a `|`.

`@str` is the line content directly from the markup file.

3) Finally, we need an output method to produce the final HTML.

```rb
  class CustomLine < MiniMark::Line

    def line_types
      [ :hint ]
    end
    
    def hint? 
      @str[0] == '|'
    end

    def hint_to_s
      str = @str.sub(/^\|/, '').strip
      return '<p class="hint">' + str + '</p>'
    end
  ...
```

This method is again named after the line type name, but suffixed with `_to_s`. The resulting HTML is nothing special, it's just a regular `p` element with a `hint` class.



