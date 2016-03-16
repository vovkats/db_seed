require "active_support/core_ext/module/delegation"
require "active_record/base"

module DbSeed
  DB_SEED__TABLE = "data_migrations"

  class Migration
    def initialize(name, version)
      @name, @version = name, version
    end

    attr_reader :version, :name

    def migrate
      begin
        announce("changing")
        time = Benchmark.measure { change }   # #change should be provided in migration class
        stamp_applied               # Put version into stamps table
        log_applied                 #
        announce("changed (%.4fs)" % time.real); write
      rescue StandardError => se
        log_error(se)               #
        raise se
      end
    end

    private

    def stamp_applied
      MigrationStamp.(version).apply
    end

    def logger
      @logger ||= self.class.custom_logger || Logger.new("log/db_seed.log")
    end

    def self.config
      ::Rails.configuration.assets[:db_seed] rescue {}
    end

    def self.custom_logger
      config[:logger] rescue nil
    end

    def self.verbose?
      verbose = config[:verbose]
      verbose.nil? || verbose
    end

    def log_applied
      logger.info("Applied seed #{version}, #{name}")
    end

    def log_error(error)
      logger.fatal(error.message + $/ +
                   (error.backtrace || [])[0, 3].join($/) +
                  $/ + "...")
    end

    def write(text="")
      puts(text) if self.class.verbose?
    end

    def announce(message)
      text = "  #{name}: #{message}"
      length = [0, 75 - text.length].max
      msg = "== %s %s" % [text, "=" * length]
      write msg
      logger.info(msg)
    end

    def say(message, subitem=false)
      msg = "#{subitem ? "   ->" : "--"} #{message}"
      write msg
      logger.info(msg)
    end
  end

  class MigrationStamp
    def self.call(version)
      new(version)
    end

    def initialize(version)
      @version = version
    end

    attr_reader :version

    def exist?
      migrated.include?(version.to_i)
    end

    def apply
      stmt = table.compile_insert table["version"] => version
      connection.insert stmt
    end

    def migrated
      @migrated ||= get_all_versions
    end

    def get_all_versions
      connection.select_values(
        table.project(table['version'])).map{ |v| v.to_i }.sort
    end

    def table
      @table ||=
        begin
          unless connection.table_exists?(DB_SEED__TABLE)
            connection.create_table DB_SEED__TABLE, id: false do |t|
              t.string "version"
            end
          end

          Arel::Table.new(DB_SEED__TABLE)
        end
    end

    def connection
      ActiveRecord::Base.connection
    end
  end

  class MigrationProxy
    def initialize(name, version, filepath)
      @name, @version, @filepath = name, version, filepath
    end

    attr_reader :name, :version

    delegate :migrate, :to => :migration

    private

    def migration
      @migration ||= load_migration
    end

    def load_migration
      load(File.expand_path(@filepath))
      @name.constantize.new(name, version)
    end
  end

  class Migrator

    def self.call(*argv)
      new(*argv).call
    end

    def initialize(*argv)
    end

    def call
      migrations.select do |migration|
        !MigrationStamp.(migration.version).exist?
      end.each(&:migrate)
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

        MigrationProxy.new(name.camelize, version, filename)
      end.sort_by(&:version)
    end

    def migrations_root
      File.join(::Rails.root, "db/seed")
    end
  end

  class InvalidNameError < StandardError; end
  class DuplicateVersionError < StandardError; end
  class DuplicateNameError < StandardError; end
end
