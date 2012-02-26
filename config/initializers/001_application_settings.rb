# Load in the application settings
# Note:: this file is named 001_... to be explicitly loaded prior to all other initializers

# TODO This will be going away once the site information is stored in the db.

app_settings_file = "#{Rails.root}/config/application_settings.yml"

APP_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load_file(app_settings_file)[Rails.env])
APP_CONFIG['use_view_objects'] = true unless APP_CONFIG.keys.include? "use_view_objects"
ActionMailer::Base.default_url_options[:host] = 'http://test.com' # APP_CONFIG['base_site_url'].sub(/^https?:\/\//,'')

Time.zone = APP_CONFIG['time_zone'] || 'Pacific Time (US & Canada)'

config_file = File.join(Rails.root, "config", "providers.yml")
config = File.exists?(config_file) ? YAML::load_file(config_file) : nil
APP_CONFIG[:omniauth] = config


# Use Bit.ly version 3 API
if defined?(Bitly)
  Bitly.use_api_version_3
end
