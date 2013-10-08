# 输入一个目录
# 返回该目录下所有的目录，递归
# 返回的是一个数组
# 使用Dir.glob会自动忽略以英文点好开头的目录
# 如 .git
module GetDir
  def get_dir(path)
    Dir["#{path}/**/*"].select { |e| File.directory? e}
  end

  module_function :get_dir
end

# 输入是一个目录
# 输出是该目录下所有文件列表，不包括以英文点开头的文件
# 输出是数组
class IndexHtml

  require 'cgi'
  require 'erubis'

  attr_accessor :path, :tpl, :domain

  def initialize(path, tpl = 'views/index-eruby.html', domain = '/')
    @path = path
    @tpl = tpl
    @domain = domain
    @context = self.context
  end

  def write
    self.del_index
    eruby = Erubis::Eruby.new(File.read(@tpl))
    index_html =  eruby.evaluate(@context)
    out = File.join(@path, 'index.html')
    p "generating #{out}"
    File.write(out, index_html)
  end

  def del_index
    Dir["#{@path}/**/index.html"].each { |e| File.delete e; p "deleting #{e}" }
  end

  #protected

  def context
    {
      :title => self.title,
      :links   => self.links,
      :domain => self.domain,
    }
  end

  def files
    Dir["#{@path}/*"].map { |e| File.basename e} # no unix dot files
  end

  def title
    @path.split('/').last
  end

  def links
    self.files.map { |e| [e, CGI.escape(e)]}.sort
  end

end

# 执行
if __FILE__ == $PROGRAM_NAME
  inputdir = ARGV[0]
  p "inputdir is #{inputdir}"
  GetDir.get_dir(inputdir).each { |e| IndexHtml.new(e).write }
end
