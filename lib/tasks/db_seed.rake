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
    task :seed => [:environment] do
      at_exit { 
        if $db_migrate_seed_completed 
          puts '', 'Все миграции ВЫПОЛНЕНЫ УСПЕШНО'
        else
          puts '', '!!!','ВОЗНИКЛА ОШИБКА, миграции не были завершены'
        end
      }
      puts "Запуск миграций схемы данных..."
      puts ''
      Rake::Task['db:migrate'].invoke
      puts "Миграции схемы данных ВЫПОЛНЕНЫ УСПЕШНО"
      puts ''
      puts "Запуск миграций данных..."
      puts ''
      Rake::Task['db:seed:apply'].invoke
      puts "Миграции данных ВЫПОЛНЕНЫ УСПЕШНО"
      puts ''
      $db_migrate_seed_completed = true
    end
  end
end
