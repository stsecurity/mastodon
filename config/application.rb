# frozen_string_literal: true

require_relative 'boot'

require 'rails'

require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
# require 'action_cable/engine'
# require 'action_mailbox/engine'
# require 'action_text/engine'
# require 'rails/test_unit/railtie'

# Used to be implicitly required in action_mailbox/engine
require 'mail'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/exceptions'
require_relative '../lib/sanitize_ext/sanitize_config'
require_relative '../lib/paperclip/url_generator_extensions'
require_relative '../lib/paperclip/attachment_extensions'
require_relative '../lib/paperclip/gif_transcoder'
require_relative '../lib/paperclip/media_type_spoof_detector_extensions'
require_relative '../lib/paperclip/transcoder'
require_relative '../lib/paperclip/type_corrector'
require_relative '../lib/paperclip/response_with_limit_adapter'
require_relative '../lib/terrapin/multi_pipe_extensions'
require_relative '../lib/mastodon/middleware/public_file_server'
require_relative '../lib/mastodon/middleware/socket_cleanup'
require_relative '../lib/mastodon/email_configuration_helper'
require_relative '../lib/mastodon/feature'
require_relative '../lib/mastodon/snowflake'
require_relative '../lib/mastodon/version'
require_relative '../lib/devise/strategies/two_factor_ldap_authenticatable'
require_relative '../lib/devise/strategies/two_factor_pam_authenticatable'
require_relative '../lib/elasticsearch/client_extensions'
require_relative '../lib/chewy/settings_extensions'
require_relative '../lib/chewy/index_extensions'
require_relative '../lib/chewy/strategy/mastodon'
require_relative '../lib/chewy/strategy/bypass_with_warning'
require_relative '../lib/rails/engine_extensions'
require_relative '../lib/action_dispatch/remote_ip_extensions'
require_relative '../lib/active_record/database_tasks_extensions'
require_relative '../lib/active_record/batches'
require_relative '../lib/simple_navigation/item_extensions'
require_relative '../lib/vite_ruby/sri_extensions'

Bundler.require(:pam_authentication) if ENV['PAM_ENABLED'] == 'true'

module Mastodon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    # config.autoload_lib(ignore: %w(assets tasks templates generators))
    # TODO: We should enable this eventually, but for now there are many things
    # in the wrong path from the perspective of zeitwerk.

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    # config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.active_job.queue_adapter = :sidekiq

    config.action_mailer.deliver_later_queue_name = 'mailers'
    config.action_mailer.preview_paths << Rails.root.join('spec', 'mailers', 'previews')

    # We use our own middleware for this
    config.public_file_server.enabled = false

    config.middleware.use Mastodon::Middleware::PublicFileServer if Rails.env.local? || ENV['RAILS_SERVE_STATIC_FILES'] == 'true'
    config.middleware.use Rack::Attack
    config.middleware.use Mastodon::Middleware::SocketCleanup

    config.before_configuration do
      require 'mastodon/redis_configuration'
      ::REDIS_CONFIGURATION = Mastodon::RedisConfiguration.new

      config.x.use_vips = ENV['MASTODON_USE_LIBVIPS'] != 'false'

      if config.x.use_vips
        require_relative '../lib/paperclip/vips_lazy_thumbnail'
      else
        require_relative '../lib/paperclip/lazy_thumbnail'
      end
    end

    config.x.cache_buster = config_for(:cache_buster)
    config.x.captcha = config_for(:captcha)
    config.x.email = config_for(:email)
    config.x.mastodon = config_for(:mastodon)
    config.x.omniauth = config_for(:omniauth)
    config.x.translation = config_for(:translation)
    config.x.vapid = config_for(:vapid)

    if ENV.fetch('QUERY_LOG_TAGS_ENABLED', 'false') == 'true'
      config.active_record.query_log_tags_enabled = ENV.fetch('QUERY_LOG_TAGS_ENABLED', 'false') == 'true'
      config.active_record.query_log_tags = [:namespaced_controller, :action, :sidekiq_job_class]
    end

    config.to_prepare do
      Doorkeeper::Application.include ApplicationExtension
      Doorkeeper::AccessGrant.include AccessGrantExtension
      Doorkeeper::AccessToken.include AccessTokenExtension
      Devise::FailureApp.include AbstractController::Callbacks
      Devise::FailureApp.include Localized
    end
  end
end
