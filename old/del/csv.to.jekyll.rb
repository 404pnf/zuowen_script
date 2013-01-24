# -*- coding: utf-8 -*-

require 'csv'
require 'yaml'
require 'fileutils'

# CSV用法参考：
# http://www.neocanable.com/ruby-csv-file/
# http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html

dir = '_posts'
file = "posts.csv"

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
  # 重排文章正文
  # 所有段落顶头
  if body.nil?
    body = "没有内容啊！"
  else
    body = body.gsub(/^ +/, '')
    body = body.gsub(/^　+/, '')
    # 段落之间有一个空行，先把所有换行替换成两个换行、再删除多余连续换行
    body = body.gsub(/\n/, "\n\n")
    body = body.gsub(/\r/, "\n\n")
    body = body.gsub(/\n\r/, "\n\n")
    body = body.gsub(/\n\n\n+/, "\n\n")
  end
  # Get the relevant fields as a hash, delete empty fields and convert
  # to YAML for the header
  data = {
    'layout' => 'post',
    'title' => title.to_s,
    #'created' => date,
    #'author' => name.to_s,
    # ruby to yaml, simple array { 'seq' => [ 'a', 'b', 'c' ] } 
    #'categories' => [district, school, ],
    #'categories' => [school],
    #'date' => date,
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
  FileUtils.mkdir("#{dir}/#{school}")  unless File.directory?("#{dir}/#{school}")
  filename = date + "-" + nid + ".markdown"
  #  File.open("#{dir}#{school}/#{filename}", "w") do |f|
  File.open("#{dir}/#{school}/#{filename}", "w") do |f|
    f.puts data
    f.puts "---"
    f.puts body
    f.puts 
    f.puts name.strip
    f.puts school.strip
    f.puts district.strip
    f.puts type.strip
    f.puts date.strip
  end

end




