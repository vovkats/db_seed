module DbSeed
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "tasks/db_seed.rake"
      end

      generators do
        require "generators/seed/seed_generator"
        require "generators/seed/initializer/initializer_generator"
      end
    end
  end
end
