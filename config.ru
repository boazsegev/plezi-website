# Default Rack interface

# load the application
load ::File.expand_path(File.join('..', 'website.rb'), __FILE__)

# Iodine options
Iodine::Rack.public = Root.join('public').to_s
Iodine::Rack.log = true
Iodine.threads ||= 16

run Plezi.app
