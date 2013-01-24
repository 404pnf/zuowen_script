# -*- coding: utf-8 -*-

require 'csv'
require 'yaml'
require 'fileutils'
require 'mysql'

begin
    con = Mysql.new 'localhost', 'root', '123465', 'zw09-csv' 
end

file = "posts-zw-2009.csv"
#file = "import.db"

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
    body = body.gsub(/ +/, " ") 
    body = body.gsub(/^ +/, "") # 段落开头的空格不要
    # 段落之间有一个空行，先把所有换行替换成两个换行、再删除多余连续换行
    body = body.gsub(/\r/, "\n")
    body = body.gsub(/\n/, "\n\n")
    body = body.gsub(/\n\n\n+/, "\n\n")
  end

  district = district.gsub(/ /, '')


 # school 是路径的一部分因此过滤不好的字符                                                                                                  
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
  # 有的名字竟然有 \t 和 \n  
  # "\t韦娅娟"    # "陆莹\n李秋根   
  # 上面的 \n 是字面量的 \n 
  # 还有有 '.' 的
  # 还有这种 哈力米艳•阿布都外力                                                                                                                      
  name = name.gsub(/[\t\n.]/, '_') #  \t \n . 是字面量
  name = name.gsub(/@/, '_')
  name = name.gsub(/_+/, '_')
  name = name.to_s.gsub(/[、()!?,？！，《》（）•]/, '_')
  name = name.to_s.gsub(/_$/, '') #最后一个 _ 不需要                                                 

# ruby and mysql

    con.query(
#      "INSERT INTO posts(author) VALUES('#{name}');
#      INSERT INTO posts(title) VALUES('#{title}');"

       "INSERT INTO posts('id' ,'title' ,'district' ,'school' ,'author' ,'type' ,'body' ,'date') VALUES (NULL , '#{title}',  '',  '',  '#{name}',  '',  '',  '');"
          
)   
=begin
  con.query("INSERT INTO posts(district) VALUES('#{district}')")
    con.query("INSERT INTO posts(type) VALUES('#{type}')")
    con.query("INSERT INTO posts(body) VALUES('#{body}')")
    con.query("INSERT INTO posts(date) VALUES('#{date}')")
    con.query("INSERT INTO posts(school) VALUES('#{school}')")
=end
# === To a File
#
#   CSV.open("path/to/file.csv", "wb") do |csv|
#     csv << ["row", "of", "CSV", "data"]
#     csv << ["another", "row"]
#     # ...
#   end
=begin
  CSV.open("csv2009.txt", "wb") do |csv|
    csv << ["#{title}" ,"#{body}", "#{name}", "#{school}", "#{district}", "#{type}", "#{date}"]
  end
=end
end
