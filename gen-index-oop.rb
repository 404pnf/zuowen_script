# ## 使用方法
#
#     ruby script.rb inputdir
#

# ## 脚本目的
#
# 递归地生成输入文件夹中所有目录的index.html文件。该文件有其所处目录的所有文件名和链接。
#
# 相比web server默认渲染的文件列表，本脚可生成自定义样式的文件列表。
#
# ----

# ## 帮助函数
#
# 1. 输入一个目录
# 1. 返回该目录下所有的目录，递归。因为使用Dir.glob因此不包含隐藏目录，即以英文 . 开头的目录
# 1. 返回的是一个数组
#
# ----
module GenIndex
  def get_dir(path)
    Dir["#{ path.chomp('/') }/**/*"].select { |e| File.directory? e } + [path] # 把输入目录添加到结果数组中
  end

  module_function :get_dir

  # ## 用类封装
  #
  # 1. 输入是一个目录。
  # 2. 输出index.html文件，内容是该目录下所有文件列表，不包括以英文点开头的文件。
  #
  # ----
  class IndexHtml

    require 'cgi'
    require 'erubis'

    attr_accessor :path, :tpl, :domain

    def initialize(path, tpl = 'index.eruby', domain = '/')
      @path = path.chomp
      @tpl = tpl
      @domain = domain
    end

    def write_index
      @context = context
      eruby = Erubis::Eruby.new(File.read(@tpl))
      index_html =  eruby.evaluate(@context)
      out = File.join(@path, 'index.html')
      p "deleting #{ out }"
      File.delete out if File.exists?(out)
      p "generating #{ out }"
      File.write(out, index_html)
    end

    private

    def context
      {
        title: title,
        links: links,
        domain: @domain,
      }
    end

    def files
      Dir["#{@path}/*"].map { |e| File.basename e } # Dir.glob, no unix dot files
    end

    def title
      @path.split('/').last
    end

    def links
      files.map { |e| [e.sub(/.html$/, ''), CGI.escape(e)] }.sort
    end

  end # end class

end # end Module

# ## 干活
def gen_index(path)
  p "输入目录是 #{path}"
  p '请检查一下输入目录是否正确！输入yes继续。输入其它任意字符退出。'
  if STDIN.getc == 'y'
    GenIndex.get_dir(path).each do |e|
      GenIndex::IndexHtml.new(e, 'views/index-eruby.html').write_index
    end
  else
    p '再来一次。这回别敲错目录了。'
  end
end

gen_index(ARGV[0]) if __FILE__ == $PROGRAM_NAME
