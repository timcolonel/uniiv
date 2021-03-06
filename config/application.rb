require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Uniiv
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a show of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    Dir["#{Rails.root}/lib/extension/*.rb"].each { |file| require file }

    config.assets.paths << "#{Rails.root}/app/assets/test"
    config.autoload_paths << "#{Rails.root}/lib/"
    config.autoload_paths << "#{Rails.root}/app/searcher/"
    silence_warnings do
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE unless Rails.env.production?
    end

    env_file = File.join(Rails.root, 'config/local', 'local_env.yml')
    if File.exists?(env_file)
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end
    else
      #unless $0.end_with?('rake')
        puts 'WARNING: Local db env file local not found!'
    end

    config.sass.preferred_syntax = :sass

    config.generators do |g|
      g.template_engine :slim
      g.test_framework  :test_unit, :fixture => false
    end
  end
end