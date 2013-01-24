# -*- coding: utf-8 -*-

require 'csv'
require 'yaml'
require 'fileutils'

# usage: scritp.rb input_csv_file outputfolder

file = File.expand_path ARGV[0]
dir = File.expand_path ARGV[1]

CSV.foreach(file, "r") do |row|
#  next if row[0] == "title" # 第一行是csv的header
  date = row[7]
  title = row[4]
  body = row[5]
  nid = row[6]
  
  school_and_district = row[1]
  grade = row[2]
  name = row[0]
  type = row[3]

  district = school_and_district.split('›')[0]
  school = school_and_district.split('›')[1]

  if title == ''  # '' != nil
    title = "notitle"
  end

  # sanitize title
  title = title.gsub(/[\t ]+/,'').strip # title前后有空格，tab等，有的title中间还有空格。都去掉
  title = title.gsub(/\//,'')
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

  if school == ''
    school = '最后是没有注明学校的文章'
  end

  # school出现在路径中，去掉任何敲写出来困难的字符
  school = school.to_s
  school = school.gsub(/ /, '')
  school = school.gsub(/[()（）]/, '_')
  school = school.gsub(/_$/, '')
  # name中也不能出现 '/'  因为一会儿要作为文件名使用 linux中 / 是路径分割符号
  if name == ''
    name = "noname"
  end
  name = name.to_s
  name = name.gsub(/ /, '').gsub(/\//, '.')
  name = name.gsub(/[\t\n.]/, '_')          
  name = name.gsub(/@/, '_')                                                                       
  name = name.gsub(/_+/, '_')
  name = name.to_s.gsub(/[、()!?,？！，《》（）•]/, '_')
  name = name.to_s.gsub(/_$/, '')                                      
  name = name.to_s.gsub(/^_/, '')   

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
    'district' => district,
    'school' => school,
    'grade' => grade,
    'type' => type,
    #'tags' => type 
  }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

  FileUtils.mkdir_p("#{dir}/#{district}qu/#{school}")  unless File.directory?("#{dir}/#{district}qu/#{school}")

  title_in_filename = title
  title_in_filename = title_in_filename.gsub(/[\t\n.]/, '_')
  title_in_filename = title_in_filename.to_s.gsub(/[-@。、()!?,？！，《》（）•+…|{}"'“”‘’]/, '_')
  title_in_filename = title_in_filename.gsub(/_+/, '_')
  title_in_filename = title_in_filename.to_s.gsub(/_$/, '') 
  title_in_filename = title_in_filename.to_s.gsub(/^_/, '')

  filename = "#{date}-#{nid}.txt"
  File.open("#{dir}/#{district}qu/#{school}/#{name}-#{title_in_filename}-#{filename}", "w") do |f|
    f.puts data
    f.puts "---"
    f.puts
    f.puts body
    f.puts
    f.puts
    f.puts name
    f.puts grade
    f.puts school
    f.puts district
    f.puts type
    f.puts date
  end
end
