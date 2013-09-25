# -*- coding: utf-8 -*-
require 'fileutils'
require 'kramdown'
require 'yaml'
require 'pathname'
require 'erubis'
require_relative 'gen_index'

def generate_zuowen(inputdir, outputdir)
  inputdir = File.expand_path ARGV[0]
  # if I name this input it conflicts with the name in input = File.read('post.eruby')
  # this is a bug that hard to catch!
  outputdir = File.expand_path ARGV[1]
  files = Dir.glob("#{inputdir}/**/*.txt") # files是数组，是带有文件路径的文件

  files.each_with_index do |fn,idx|
    content = File.read(fn)
    yaml_front, body =  content.split(/---\n\n/)
    mytitle = YAML.load(yaml_front)['title']
    # p mytitle
    html_body = Kramdown::Document.new(body, :auto_ids => false).to_html
    newfn = fn.sub("#{inputdir}", outputdir)
    newfn = newfn.sub(/txt$/, 'html') # 且文件后缀改为html
    newfn_path = Pathname.new(newfn).dirname
    FileUtils.mkdir_p newfn_path unless File.directory?(newfn_path)
    # here comes erubis
    input = File.read('post.eruby')
    eruby = Erubis::Eruby.new(input)    # create Eruby object
    context = {
      :mytitle => mytitle,
      :html_body => html_body,
    }
    article_html =  eruby.evaluate(context)        # get result
    # same old file writing
    p "generating #{newfn}"
    File.write(newfn, article_html)
    (puts '100 articles generated' ; break) if idx == 10
  end
end

if __FILE__ == $PROGRAM_NAME
  inputdir = ARGV[0]
  outputdir = ARGV[1]
  p "inputdir is #{inputdir}"
  p "DOMAIN is: #{DOMAIN}"
  generate_zuowen inputdir, outputdir
  remove_index outputdir
  gen_index outputdir
end
