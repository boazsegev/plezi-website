# Default Rack interface

# load the application
load ::File.expand_path(File.join('..', 'website.rb'), __FILE__)

# Iodine options
Iodine::DEFAULT_HTTP_ARGS[:public] = Root.join('public').to_s
Iodine::DEFAULT_HTTP_ARGS[:log] = true
Iodine.threads ||= 16

run Plezi.app
