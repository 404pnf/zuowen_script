require_relative 'zuowen_gen.rb'
require_relative 'gen-index-oop.rb'

# ## a timer
def time(&block)
  t = Time.now
  result = block.call
  puts "\nCompleted in #{(Time.now - t)} seconds\n\n"
  result
end

desc "help msg"
task :help do
  system('rake -T')
end

desc "generate html"
task :gen do
  time { gen_zuowen }
end

desc "generate index html"
task :index do
  time { gen_index }
end

desc "deploy"
task :deploy do
  #system("rsync -avz _output/* wxkj:/var/www/ilearning/video/")
  puts "\n\n同步到服务器了"
end

desc "generate and deploy"
task :all => [:gen, :deploy] do
  puts "\nRake: 生成html并部署到服务器了。"
end

desc "preview html"
task :preview do
  system("cd output; python -m SimpleHTTPServer")
end

desc "generating docs"
task :doc do
  system("docco *.rb")
end

desc "show stats of line of code "
task :loc do
  system("cloc *.rb")
end

desc "run robocop"
task :cop do
  system("rubocop *.rb")
end

desc "doc, cop and loc"
task :test => [:doc, :cop, :loc]

task :default => [:help]
