# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/vendor/qrcode_rb0.50beta8 )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_smillie_session',
    :secret      => 'fe44c91325738a8a92b6eced7a490287bcb10aa0821f186ec90ad94843f1fa6b859e59ef01df927d23ad6d563f0eafdfc9f8ae7d78ed7d5cfbaa8c9d4622b7de'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  if File.exist?('/usr/sbin/rotatelogs')
    config.logger = Logger.new(open("|/usr/sbin/rotatelogs #{config.log_path}.%Y%m%d 86400 540", "w"))
  end
end

APP_DOMAIN = "smillie.jp"
ADMIN_EMAIL = "admin@smillie.jp"

File.umask 0002
require "tmail_address_ext"
require "date_helper_ext"
require "gettext/rails"
require "nkf"
GetText.locale = "ja"

#送付先変更
ExceptionNotifier.exception_recipients = %w(admin@smillie.jp)
#送信者を変更
ExceptionNotifier.sender_address = %("Smillie Admin" <admin@smillie.jp>)
#件名の prifix を変更
ExceptionNotifier.email_prefix = "[Smillie!] "
