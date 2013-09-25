# -*- coding: utf-8 -*-
require 'fileutils'
require 'kramdown'
require 'yaml'
require 'pathname'
require 'erubis'
require_relative 'gen_index'

def generate_zuowen(inputdir, outputdir)
  files = Dir.glob("#{inputdir}/**/*.txt") # files是数组，是带有文件路径的文件

  files.each_with_index do |fn,idx|
    content = File.read(fn)
    yaml_front, body =  content.split(/---\n\n/)
    mytitle = YAML.load(yaml_front)['title']
    # p mytitle
    html_body = Kramdown::Document.new(body, :auto_ids => false).to_html
    newfn = fn.sub(inputdir, outputdir)
    # 刘嘉佩-城市_让生活更美好-2009-09-29-16293.txt
    # > s.partition(/-20[0-9]{2}-[0-9]{2}-[0-9]{2}/)
    # => ["刘嘉佩-城市_让生活更美好", "-2009-09-29", "-16293.html"]
    # newfn = newfn.sub(/txt$/, 'html') # 且文件后缀改为html
    newfn = newfn.partition(/-20[0-9]{2}-[0-9]{2}-[0-9]{2}/)[0] + '.html'
    newfn_path = Pathname.new(newfn).dirname
    FileUtils.mkdir_p newfn_path unless File.directory?(newfn_path)
    # here comes erubis
    input = File.read('views/post-eruby.html')
    eruby = Erubis::Eruby.new(input)    # create Eruby object
    context = {
      :mytitle => mytitle,
      :html_body => html_body,
    }
    article_html =  eruby.evaluate(context)        # get result
    # same old file writing
    p "generating #{newfn}"
    File.write(newfn, article_html)
    (puts '100 articles generated' ; break) if idx == 1000
  end
end

def copy_asset_to_output
  # If you want to copy all contents of a directory instead of the
  # directory itself, c.f. src/x -> dest/x, src/y -> dest/y,
  # use following code.
  # cp_r('src', 'dest') makes dest/src,
  # but this doesn't.
  FileUtils.cp_r 'views/.', '_output', :verbose => true
end

if __FILE__ == $PROGRAM_NAME
  inputdir = ARGV[0] || '_posts_txt'
  outputdir = ARGV[1] || '_output/html'
  p "inputdir is #{inputdir}"
  p "outputdir is #{outputdir}"
  generate_zuowen inputdir, outputdir
  remove_index outputdir
  gen_index outputdir
  copy_asset_to_output
end
