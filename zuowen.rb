# -*- coding: utf-8 -*-
require 'fileutils'
require 'kramdown'

input = ARGV[0]
output = ARGV[1]

input = input.sub('/', '') # de-slash 如果输入目录的时候有斜杠
output = output.sub('/', '') # de-slash 如果输出目录的时候有斜杠

files = Dir.glob("#{input}/**/*.txt") # files是数组，是带有文件路径的文件

files.each do |fn| 
  mytitle = fn.split('/')[2].sub(/-20..*$/, '') # 用文件名的部分做html head中標題
  # p fn
  # p mytitle
  content = IO.read(fn)
  # title 是作文題目
  title =  content.split(/---\n\n/)[0] # yaml frontmatter
  title = title.split(/\n/)[2].sub('title: ', '') #每篇文章的title都是第3行
  # p title
  body = content.split(/---\n\n/)[1] # 作文正文
  # p body
  newfn = fn.sub(/^#{input}/, "#{output}") 
  # 新文件名，在html目录；不用担心文件名中出现posts也会被替换，以为我用的是sub，只替换找到的第一个匹配
  newfn = newfn.sub(/txt$/, 'html') # 且文件后缀改为html

  html_content = Kramdown::Document.new(body, :auto_ids => false).to_html
  html_header = <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>#{mytitle}</title>
    <link href="/css/local.css" rel="stylesheet">
    </head>
    <body>
EOF
  html_footer = <<EOF
    </body>
    <footer>
    <hr>
    <a href="./">更多该校文章</a>
    <a href="/">主页</a>
    </footer>
</html>
EOF

  File.open(newfn, 'w') do |f|
    f.puts html_header
    f.puts "<h1>#{title}</h1>"
    f.puts html_content
    f.puts html_footer
  end

end
