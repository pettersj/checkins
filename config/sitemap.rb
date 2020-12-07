# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.letscheckin.co"
SitemapGenerator::Sitemap.public_path = 'tmp/sitemap'
SitemapGenerator::Sitemap.sitemaps_host = "http://letscheckin-sitemap.s3-eu-west-1.amazonaws.com/"

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new('s3_bucket',
  aws_access_key_id: Rails.application.credentials[:aws][:access_key_id],
  aws_secret_access_key: Rails.application.credentials[:aws][:secret_access_key],
  aws_region: 'eu-west-1'
)


SitemapGenerator::Sitemap.create_index = true



SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
    # add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  add new_user_registration_path
  add new_user_session_path
  add new_user_password_path
  add '/terms'
  add '/privacy'
  add '/refund'

end
