# using 20xx-csv2txt.rb to generate plain text files from db.csv

usage:

    2011-csv2txt.rb db.csv outpudir

# convert plain text files to html files

usage:

    zuowen.rb inputdir outputdir

to change layout, cusomize post.eruby

# generate index.html for website

usauge:

   gen_index.rb dir

to change layout, customize index.eruby 

# how to make a proper <br> in kramdown

> Notice that a line break in the source does not mean a line break in the output (due to the lazy syntax)!. If you want to have an explicit line break (i.e. a <br /> tag) you need to end a line with two or more spaces or two backslashes! Note, however, that a line break on the last text line of a paragraph is not possible and will be ignored. Leading and trailing spaces will be stripped from the paragraph text.
<http://kramdown.rubyforge.org/syntax.html>

I decided not to regeneate all plain text files just to get a correct br tag. Without line break, the aritcle info line in html file is more compact.

# 在办公室imac上生成整个站点花了23分钟

