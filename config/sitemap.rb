# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = APP_CONFIG['base_url']

SitemapGenerator::Sitemap.add_links do |sitemap|
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: sitemap.add path, options
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host


  # Examples:

  # add '/stories'
  sitemap.add stories_path, :priority => 0.7, :changefreq => 'daily'

  # add all individual stories
  Content.find(:all).each do |a|
    sitemap.add story_path(a), :lastmod => a.updated_at
  end

end

# Including Sitemaps from Rails Engines.
#
# These Sitemaps should be almost identical to a regular Sitemap file except
# they needn't define their own SitemapGenerator::Sitemap.default_host since
# they will undoubtedly share the host name of the application they belong to.
#
# As an example, say we have a Rails Engine in vendor/plugins/cadability_client
# We can include its Sitemap here as follows:
#
# file = File.join(Rails.root, 'vendor/plugins/cadability_client/config/sitemap.rb')
# eval(open(file).read, binding, file)