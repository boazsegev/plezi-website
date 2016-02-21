# encoding: UTF-8

ENV['ENV'] ||= ENV['RACK_ENV'] || 'production'
## Set working directory, load gems and create logs
	## Using pathname extentions for setting public folder
	require 'pathname'
	## Set up root object, it might be used by the environment and\or the plezi extension gems.
	Root ||= Pathname.new(File.dirname(__FILE__)).expand_path
	## If this app is independant, use bundler to load gems (including the plezi gem).
	## otherwise, use the original app's Gemfile and Plezi will automatically switch to Rack mode.
	require 'bundler'
	Bundler.require(:default, ENV['ENV'].to_s.to_sym)

# # Optional code auto-loading and logging:

	# # Load code from a subfolder called 'app'?
	Dir[File.join "{app}", "**" , "*.rb"].each {|file| load File.expand_path(file)}

	## Log to a file?
	# Iodine.logger = Logger.new Root.join('server.log').to_s

# # Optional Scaling (across processes or machines):
	ENV['PL_REDIS_URL'] ||= ENV['REDIS_URL'] ||
							ENV['REDISCLOUD_URL'] ||
							ENV['REDISTOGO_URL'] ||
							nil # "redis://username:password@my.host:6389"
	# # redis channel name should be changed is using Placebo API
	# Plezi::Settings.redis_channel_name = 'website_6a46dee9baf26132917c5392ddcb504b'

	# # uncomment to set up forking for 3 more processes (total of 4).
	# Iodine.processes = 4

# change some of the default settings here.
host templates: Root.join('docs').to_s,
	public: Root.join('public').to_s,
	assets: Root.join('assets').to_s

# # I18n re-write, i.e.: `/en/home` will be rewriten as `/home`, while setting params[:locale] to "en"
# route "/:locale{#{I18n.available_locales.join "|"}}/*" , false if defined? I18n

# # OAuth2 - Facebook / Google authentication
# ENV["FB_APP_ID"] ||= "app id"; ENV["FB_APP_SECRET"] ||= "secret"; ENV['GOOGLE_APP_ID'] = "app id"; ENV['GOOGLE_APP_SECRET'] = "secret"
# require 'plezi/oauth' # do this AFTER setting ENV variables.
# create_auth_shared_route do |service_name, auth_token, remote_user_id, remote_user_email, remote_response|
#         # ...callback for authentication.
#         # This callback should return the app user object or false
#         # This callback has access to the controller's methods (request, cookies, response, etc')
# end

# Add your routes and controllers by order of priority.
route '/docs', DocsController
route '/guides', DocsController
route '/', HomeController

require 'logger'
class ::Logger; alias_method :write, :<<; end
Plezi.middleware Rack::ShowExceptions
# Plezi.middleware Rack::CommonLogger, ::Logger.new(STDERR)
