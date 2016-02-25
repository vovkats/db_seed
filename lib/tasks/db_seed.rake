require 'active_support/core_ext/object/inclusion'
require 'active_record'
require "db_seed/migrator"

db_namespace = namespace :db do

  # def database_url_config
  #   @database_url_config ||=
  #       ActiveRecord::Base::ConnectionSpecification::Resolver.new(ENV["DATABASE_URL"], {}).spec.config.stringify_keys
  # end

  def current_seed_config(options = {})
    options = { :env => Rails.env }.merge! options

    if options[:config]
      @current_config = options[:config]
    else
      @current_config ||= if ENV['DATABASE_URL']
                            database_url_config
                          else
                            ActiveRecord::Base.configurations[options[:env]]
                          end
    end
  end

  task :load_seed_config do
    ActiveRecord::Base.configurations = Rails.application.config.database_configuration
    ActiveRecord::Migrator.migrations_paths = Rails.application.paths['db/seed'].to_a

    if defined?(ENGINE_PATH) && engine = Rails::Engine.find(ENGINE_PATH)
      if engine.paths['db/migrate'].existent
        ActiveRecord::Migrator.migrations_paths += engine.paths['db/seed'].to_a
      end
    end
  end

  desc "Foobar"
  task :foobar do
    DbSeed::Migrator.new.()
  end
end
