# 生成站点

		zuowen_gen.rb _csv/new-2011.csv
		zuowen_gen.rb _csv/new-2009.csv

生成的html在_output目录。

修改文章模版 views/post-eruby.html

# generate index.html for website

usauge:

   gen-index-oop.rb _output

to change layout, customize views/index-eruby.html

# how to make a proper <br> in kramdown

> Notice that a line break in the source does not mean a line break in the output (due to the lazy syntax)!. If you want to have an explicit line break (i.e. a <br /> tag) you need to end a line with two or more spaces or two backslashes! Note, however, that a line break on the last text line of a paragraph is not possible and will be ignored. Leading and trailing spaces will be stripped from the paragraph text.
<http://kramdown.rubyforge.org/syntax.html>

I decided not to regeneate all plain text files just to get a correct br tag. Without line break, the aritcle info line in html file is more compact.

# 在办公室imac上生成整个站点花了13分钟

