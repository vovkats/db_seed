require "active_support/core_ext/module/delegation"

module DbSeed
  class Migration
    def migrate
      unless already_applied?
        begin
          change
          stamp_applied
          log_applied
        rescue StandardError => se
          log_error(se)
          raise se
        end
      end
    end

    private

    def already_applied?
      true
    end

    def stamp_applied
      # TODO
    end

    def log_applied
      # TODO
    end

    def log_error(error)
      # TODO
    end
  end

  class MigrationProxy
    def initialize(name, version, filepath)
      @name, @version, @filepath = name, version, filepath
    end

    delegate :migrate, :to => :migration

    private

    def migration
      @migration ||= load_migration
    end

    def load_migration
      load(File.extend_path(@filepath))
      @name.constantize.new
    end
  end

  class Migrator

    def initialize
    end

    def call

    end

    private

    def migrations
      seen = {}
      Dir[File.join(migrations_root, "*.rb")].map do |filename|
        version, name = File.basename(filename).scan(/^(\d{14})_([_a-z0-9]+)\.rb$/).first

        if version && name
          raise DuplicateVersionError.new(filename) if seen[version]
          raise DuplicateNameError.new(filename) if seen[name]

          seen[version] = seen[name] = true
        else
          raise InvalidNameError.new(filename)
        end

        Migration.new(name, version, filename)
      end
    end

    def migrations_root
      File.join(::Rails.root, "db/seed")
    end
  end

  class InvalidNameError < StandardError; end
  class DuplicateVersionError < StandardError; end
  class DUplicateNameError < StandardError; end
end
