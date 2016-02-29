class SeedGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_data_migration
    template "seed.rb.erb", "db/seed/#{next_migration_number}_#{file_name}.rb"
  end

  private

  def current_migration_number
    filename = Dir[File.join(Rails.root, "db/seed", "*.rb")].sort.last
    File.basename(filename)[/^\d+/].to_i
  end

  def next_migration_number
    last_num = current_migration_number + 1
    if ActiveRecord::Base.timestamped_migrations
      [Time.now.strftime("%Y%m%d%H%M%S"), "%.14d" % last_num].max
    else
      "%.3d" % last_num
    end
  end
end
