require 'fileutils'
require 'cgi'
require 'find'
require 'erubis'
# USAGE: ruby script.rb input-dir domain-name
# 脚本进入dir，生成文件列表index.html

inputdir = File.expand_path ARGV[0] || '/tmp'
DOMAIN = ARGV[1] || 'http://example.com/'

def remove_index(inputdir)
  Find.find(inputdir) do |path|
    next unless File.basename(path) == 'index.html'
    #p "remove #{path}"
    File.unlink path
  end
end

def gen_index(dir)
  Find.find(dir) do |f|
    next unless File.directory?(f)

    *_, title = f.to_s.split('/')
    filelist = Dir.entries(f).reject! {|i| i == '.' or i == '..'}
    links = filelist.sort.map { |filename| [filename.sub(/.html$/, ''), CGI.escape(filename)] }

    input = File.read('views/index-eruby.html')
    eruby = Erubis::Eruby.new(input)    # create Eruby object
    index_html =  eruby.result(binding) # get result

    File.write("#{f}/index.html", index_html)
  end
end

if __FILE__ == $PROGRAM_NAME
  p "inputdir is #{inputdir}"
  p "DOMAIN is: #{DOMAIN}"
  remove_index inputdir
  gen_index inputdir
end
