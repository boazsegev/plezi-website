# The basic website controller, to get you started
class HomeController
	# HTTP
	def sitemap
		self.class.sitemap(request)
	end
	def self.sitemap request
		return @sitemap if @sitemap
		sitemap = String.new
		sitemap << '<?xml version="1.0" encoding="UTF-8"?>'
		sitemap << "\n"
		sitemap << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
		sitemap << "\n"
		sitemap << " <url>\n"
		sitemap << "  <loc>#{request.base_url}</loc>\n"
		sitemap << "  <lastmod>#{File.mtime(Root.join 'docs', 'welcome.html.slim').strftime("%Y-%m-%d")}</lastmod>\n"
		sitemap << "  <priority>1</priority>\n"
		sitemap << " </url>\n"
		Dir[Root.join('docs', 'guides', '**').to_s].each do |f|
			name = f.match(/([^\.\/\\]+)\.html\.md$/i)
			next unless name
			name = name[1]
			next if name =~ /sidebar/i
			sitemap << " <url>\n"
			sitemap << "  <loc>#{request.base_url}/docs/#{name}</loc>\n"
			sitemap << "  <lastmod>#{File.mtime(f).strftime("%Y-%m-%d")}</lastmod>\n"
			sitemap << "  <priority>#{ name =~ /basics/i ? 0.9 : 0.8}</priority>\n"
			sitemap << " </url>\n"
		end
		sitemap << "</urlset>"
		@sitemap = sitemap
	end
end

# <?xml version="1.0" encoding="UTF-8"?>
# <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
#    <url>
#       <loc>http://www.example.com/</loc>
#       <lastmod>2005-01-01</lastmod>
#       <changefreq>monthly</changefreq>
#       <priority>0.8</priority>
#    </url>
# </urlset> 
