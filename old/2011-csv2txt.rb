# -*- coding: utf-8 -*-

require 'csv'
require 'yaml'
require 'fileutils'
require_relative './utils.rb'

# usage: scritp.rb input_csv_file outputfolder

file = File.expand_path ARGV[0]
dir = File.expand_path ARGV[1]

CSV.foreach(file, "r") do |row|
  #  next if row[0] == "title" # 第一行是csv的header
  # a, b, c = [1,2,3] ; a = 1 ; b = 2; c = 3
  name, school_and_district, grade, type, title, body, nid, date = row
  district, school = school_and_district.split(/›/)
  district = '最后是没有选择区的' if district.nil? or district == ''
  school = '最后是没有选择学校的' if school.nil? or school == ''
  # school出现在路径中，去掉任何敲写出来困难的字符
  school = sanitize_filename school
  title = "最后是没有写标题的" if title == ''  or title.nil?
  title =  title.gsub(/\s+/, ' ')
  body = normalize_body_text body
  name = "noname" if name == ''
  name = sanitize_filename name

  title_in_filename = title
  title_in_filename = sanitize_filename title
  uniq_id = "#{date}-#{nid}"

  # Get the relevant fields as a hash, delete empty fields and convert
  # to YAML for the header
  data = {
    'layout' => 'post',
    'title' => title.to_s,
    'author' => name.to_s,
    'date' => date,
    'district' => district,
    'school' => school,
    'grade' => grade,
    'type' => type,
  }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

  FileUtils.mkdir_p("#{dir}/#{district}/#{school}")  unless File.directory?("#{dir}/#{district}/#{school}")

  File.open("#{dir}/#{district}/#{school}/#{name}-#{title_in_filename}-#{uniq_id}.txt", "w") do |f|
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
