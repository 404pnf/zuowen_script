# ## usage:

#     scritp.rb input_csv_file
# ----

# ## 需要的库
require 'csv'
require 'yaml'
require 'fileutils'
require 'erubis'
require 'kramdown'

# ----

# ## 数据文件格式

# 数据文件是09年和11年上海中学生作文比赛。从drupal站点导出为csv格式。
# 确保csv的headers包含以下信息并且拼写正确。因为这些header字符会作为键出现在模版文件中。

# name, title, body, date, district, school

# 必须有至少以上几个header的数据，且header名称拼写必须和上面完全一样

# ----

# ## 帮助函数

# 如果有文本字段会作为文件名使用，那么去除特殊字符
# 对于作文正文，将其格式处理整齐

module ZuowenHelper

  def sanitize_filename str
    return '' if str.nil?
    str.gsub(/[-@\s\n.、()!?,？！，《》（）•^"\[\]\/“”]/, '_')
      .gsub(/_+/, '_')
      .gsub(/_$/, '')
      .gsub(/^_/, '')
  end

  # 重排文章正文
  # 所有段落顶头

  def normalize_body_text str
    return '' if str.nil?
    str.to_s.gsub(/\t/, " ") # no tabs
      .gsub(/^ +/, "") # 段落开头的空格不要
      .gsub(/\r/, "\n")   # 段落之间有一个空行，先把所有换行替换成两个换行、再删除多余连续换行
      .gsub(/\n/, "\n\n")
      .gsub(/\n\n+/, "\n\n")
  end

  module_function :sanitize_filename, :normalize_body_text
end

# ## 封

class ZuowenFile
  include ZuowenHelper

  # 注意这几个常量
  # 我现在的水平也就这么写了
  TPL = 'views/newpost-eruby.html'
  OUTPUT = '_newoutput'

  # hash的键就是csv的header，转为了symbol
  def initialize(csv)
    @h = csv.to_hash # 必须有这个 to_hash 因为不能直接将csv::table作为hash使用
    @h[:title] = @h[:title].gsub(/\s+/, ' ').strip
    @h[:body] = normalize_body_text @h[:body]
    @h[:body] = Kramdown::Document.new(@h[:body], :auto_ids => false).to_html
    @h[:title_in_filename] = sanitize_filename(@h[:title])
    @h[:name] = sanitize_filename @h[:name]
    @h[:year] = @h[:date].slice(0..3) # :date -> 2009-10-21
    @context = @h.dup
  end

  # 绑定@context到eruby模版
  def write
    FileUtils.mkdir_p(self.folder) unless File.exists?(self.folder)
    eruby = Erubis::Eruby.new(File.read(TPL))
    post =  eruby.evaluate(@context)
    out = File.join(self.folder, self.filename + '.html')
    p "generating #{out}"
    File.write(out, post)
  end

  protected

  # 单篇文章的文件名，格式 姓名_文章标题
  def filename
    @context[:name] + '_' + @context[:title_in_filename]
  end

  # 生成的文件夹，格式 输出目录 / 年 / 区 / 学校
  def folder
    File.join(OUTPUT, @context[:year], @context[:district], @context[:school])
  end

end

# ## 脚本
if __FILE__ == $PROGRAM_NAME
  # 计时
  start = Time.now
  input = ARGV[0] || '_csv/new-2009.csv'
  # || '_csv/new-2011.csv'
  # converters: nil 是为了不把数字撰文fixnum，保持string
  # 这样在如果使用这些数字作为文件名等，不需要做to_s
  CSV.table(input, converters: nil).each { |e| ZuowenFile.new(e).write}
  duration = (Time.now - start).div 60
  puts "耗时 #{duration} 分钟"
end

# ## 一些处理CSV文件相关的命令

# CSV header, no space is allowed, space will be converted to underscore '_'
# name,school_and_district,grade,type,title,body,nid,date

# 如果csv某列数据为空，那么会是空字符串 ""

# 使用CSV#table时添加 converters: nil
# 否则会把数字转换为fixnum。我不希望这样
#   c = CSV.table('t.csv', converters: nil, force_quotes: true)

# 把CSV::Table转换为字符串
#     > cc.class
#     => CSV::Table
#     > cc.to_csv(headers: true, force_quotes: true)
#     => "\"a\",\"b\"\n\"1\",\"2\"\n"
# to_csv(options = Hash.new) click to toggle source Returns the table as
# a complete CSV String. Headers will be listed first, then all of the
# field rows.
# This method assumes you want the #headers, unless you explicitly pass :write_headers => false.

# ## 我们预处理一下数据文件

# ### 之前的数据库中有一些文章信息不全，这里我们先删除这些条目

#     >> require 'csv'
#     => true
#     >> c = CSV.table '2011.csv', converters: nil; nil
#     => nil

#     >> c.select { |e| e[:name] == '' || e[:school_and_district] == '' || e[:title] == '' }.size
#     => 479
#     >> c.delete_if { |e| e[:name] == '' || e[:school_and_district] == '' || e[:title] == '' }.size
#     => 35791

# 有些学生的姓名中竟然也含有'/' 这种字符
#     >> c.select { |e| e[:name] =~ /\// }
#     => [#<CSV::Row name:"hu/qianqian"
# 在后面也要处理。

# 2009年还有些文章body也是空的，也去除掉
#     >> c.delete_if { |e| e[:name] == '' || e[:school] == '' || e[:title] == '' || e[:district] == '' || e[:date] == '' || e[:body] == '' }

# 2009年还有写文章body只有一些换行符
#     >> c.select { |e| e[:body] =~ /\A\s+\z/ }.size=> 41
# 举例
# #<CSV::Row title:"在迎接世博的日子里" body:"\n" nid:"52753" date:"2009-10-24"
# #<CSV::Row title:"漫谈城市未来" body:"\n" nid:"54559" date:"2009-10-24"

# 这个bug非常隐蔽，引起的错误是
# initialize': undefined method `[]=' for nil:NilClass (NoMethodError)

# ### 把删除了无效条目的后的csv存起来
#     >> cc = c.to_csv(headers: true, force_quotes: true);nil
#     => nil
#     >> File.write('new-2011.csv', cc)
#     => 106280824

# ----

# 方便将数组转为csv字符串的库
# 其实csv自己带了这个
# CSV#
class Array
  require 'csv'
  def to_csv
    each_with_object('') { |e, o| o << CSV.generate_line(e, headers: true, force_quotes: true)}
  end
end
