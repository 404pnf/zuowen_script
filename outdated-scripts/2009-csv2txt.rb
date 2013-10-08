require 'csv'
require 'yaml'
require 'fileutils'
require_relative './utils.rb'

file = File.expand_path ARGV[0] || '_csv/posts-zw-2009.csv'
dir = File.expand_path ARGV[1]  || '_posts_txt/2009'

# sanitize_filename and normalize_body_text defined in utils.rb

CSV.foreach(file, "r") do |row|
  next if row[0] == "title" # 第一行是csv的header
  title, body, nid, date, district, school, name, type = row

  title = "最后是没有写标题的"   if title.to_s.empty?
  title = title.gsub(/\s/, '')
  body = normalize_body_text body
  district = district.gsub(/ /, '')
  district = '最后是没有选择区的' if district.to_s.empty?
  district = sanitize_filename district
  school = school.gsub(/ /, '')
  school = '最后没有选择学校的' if school.to_s.empty? # nil.to_s.empty? => true
  school = sanitize_filename school
  name = "最后是没有写名字的" if name.to_s.empty?
  name = sanitize_filename name
  # Get the relevant fields as a hash, delete empty fields and convert
  # to YAML for the header
  data = {
    'layout' => 'post',
    'title' => title.to_s,
    'author' => name.to_s,
    # ruby to yaml, simple array { 'seq' => [ 'a', 'b', 'c' ] }
    # 'categories' => [district, school, ],
    'date' => date,
    'school' => school,
    'district' => district,
    'type' => type,
    #'tags' => type
  }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

  FileUtils.mkdir_p("#{dir}/#{district}/#{school}")  unless File.directory?("#{dir}/#{district}/#{school}")

  title_in_filename = sanitize_filename title
  uniq_id = "#{date}-#{nid}"
  write_out_fn = "#{dir}/#{district}/#{school}/#{name}-#{title_in_filename}-#{uniq_id}.txt"
  File.open(write_out_fn, "w") do |f|
    f.puts data
    f.puts "---"
    f.puts
    f.puts
    f.puts body
    f.puts
    f.puts
    f.puts name
    f.puts school
    f.puts district
    f.puts type
    f.puts date
  end
  p "#{write_out_fn} generated."

end