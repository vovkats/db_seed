require 'active_support/core_ext/object/inclusion'
require 'active_record'
require "db_seed/migration"

namespace :db do

  namespace :seed do
    desc "Apply data migrations"
    task :apply => [:environment, "db:load_config"] do
      DbSeed::Migrator.()
    end
  end

  namespace :migrate do
    desc "Migrate database scheme, then apply data migrations"
    task :seed => ["db:migrate", "db:seed:apply"]
  end
end
