# set the working directory
Dir.chdir ::File.expand_path(File.join(__FILE__, ".."))
# load the website-app
load ::File.expand_path(File.join("..", "website.rb"),  __FILE__)
# load Rack application
run Plezi.app
