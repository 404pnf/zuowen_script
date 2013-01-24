#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'fileutils'
require 'cgi'
require 'find'
require 'erubis'
# USAGE: ruby script.rb input-dir domain-name
# 脚本进入dir，生成文件列表index.html

$inputdir = File.expand_path ARGV[0]
DOMAIN = ARGV[1] || 'http://zuowen.2u4u.com.cn/'
p "DOMAIN is: #{DOMAIN}"

def remove_index
  Find.find(File.expand_path($inputdir)) do |path|
    next unless File.basename(path) == 'index.html'
    p "remove #{path}"
    File.unlink path
  end
end
remove_index # remove previously generated html

dir = $inputdir
Find.find(dir) do |f|
  next unless File.directory?(f)
  # filelist is an array holds filename
  filelist = Dir.entries(f) # filelist is an array with all files include '.' and '..'
    .reject! {|i| i == '.' or i == '..'}
  filenames = filelist.map { |i| i.sub(/-20\d\d-.+html$/, '')} # don't show datea and uniq id 
  # urls is an array holds CGI::escapde filenames
  urls= filelist.map do |filename|
    CGI::escape(filename)
    # url = URI::encode(fn)  在ruby 1.9中会报 URI.escape is obsolete 过时啦
  end
  # zip it up :)
  links = filenames.zip  urls
  p links

  title = f.to_s.split('/').last

  # here comes erubis
  input = File.read('index.eruby')
  eruby = Erubis::Eruby.new(input)    # create Eruby object
  index_html =  eruby.result(binding())        # get result  

  # same old file writing
  p "generating #{f}/index.html"
  File.open("#{f}/index.html", "w") do |file|
    file.puts index_html
  end
end
