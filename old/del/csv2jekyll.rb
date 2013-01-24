# -*- coding: utf-8 -*-

require 'csv'
require 'yaml'
require 'fileutils'

dir = '2009'
file = "posts-zw-2009.csv"

CSV.foreach(file, "r") do |row|
  next if row[0] == "title" # 第一行是csv的header
  date = row[3]
  title = row[0]
  body = row[1]
  nid = row[2]
  district = row[4]
  school = row[5]
  name = row[6]
  type = row[7]

  # sanitize title
  title = title.gsub(/[\t ]+/,' ').strip # title前后有空格，tab等，有的title中间还有空格。都去掉
  title = title.gsub(/ +/,'')
  title = title.gsub(/\//,'')
  if title == ''  # '' != nil
    title = "notitle"
  end
  # 重排文章正文
  # 所有段落顶头
  if body == ''
    body = "没有内容啊！"
  else
    body = body.gsub(/\t/, " ") # tab不要，要空格
    body = body.gsub(/^ +/, "") # 段落开头的空格不要
    body = body.gsub(/ +/, " ") # 段落开头的空格不要
    # 段落之间有一个空行，先把所有换行替换成两个换行、再删除多余连续换行
    body = body.gsub(/\r/, "\n")
    body = body.gsub(/\n/, "\n\n")
    body = body.gsub(/\n\n\n+/, "\n\n")
  end

  district = district.gsub(/ /, '').to_s
  # name中也不能出现 '/'  因为一会儿要作为文件名使用 linux中 / 是路径分割符号
  name = name.gsub(/ /, '').gsub(/\//, '.').to_s 
  
  if name == ''
    name = "noname"
  end

  # Get the relevant fields as a hash, delete empty fields and convert
  # to YAML for the header
  data = {
    'layout' => 'post',
    'title' => title.to_s,
#    'created' => date,
    'author' => name.to_s,
    # ruby to yaml, simple array { 'seq' => [ 'a', 'b', 'c' ] } 
   # 'categories' => [district, school, ],
    'date' => date,
    'school' => school,
    'district' => district,
    'type' => type,
    #'tags' => type 
  }.delete_if { |k,v| v.nil? || v == ''}.to_yaml


  # Write out the data and content to file
  # 先生成相应的学校名字文件夹
  # 否则有问题
  # 而且我用了一个应该是很傻的方法，但我不知到其它方法。
  # 如果已经有了目录再用mkdir就报错，因此要先检测一下只有该目录不存在时才创建
  # 参考： http://ruby-doc.org/core-1.9.3/Dir.html#method-c-exist-3F
  # 参考： http://www.ruby-doc.org/stdlib-1.9.3/libdoc/fileutils/rdoc/FileUtils.html#method-c-mkdir
  # 创建目录的时候一定要注意当前目录是什么，否则会出错
  # 参考： http://stackoverflow.com/questions/6566884/rubys-file-open-gives-no-such-file-or-directory-text-txt-errnoenoent-er
#=begin
  FileUtils.mkdir("#{dir}/#{school}")  unless File.directory?("#{dir}/#{school}")

#  filename = "#{date}-#{nid}.markdown"
  filename = "#{date}-#{nid}.txt"
  File.open("#{dir}/#{school}/#{name}-#{title}-#{filename}", "w") do |f|
#  File.open("#{dir}/#{school}/#{}#{filename}", "w") do |f|
    f.puts data
    f.puts "---"
    f.puts
    f.puts
    f.puts body
    f.puts
    f.puts
    f.puts name
    f.puts school
    f.puts district
    f.puts type
    f.puts date
  end
#=end

end




