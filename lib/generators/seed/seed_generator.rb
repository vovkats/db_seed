class SeedGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_data_migration
    template "seed.rb.erb", "db/seed/#{timestamp}_#{file_name}.rb"
  end

  private

  def current_migration_number(dirname)
    filename = Dir[File.join(dirname, "*.rb")].sort.last
    File.basename(filename)[/^\d+/].to_i
  end

  def next_migration_number(dirname)
  end

  def timestamp
    Time.now.strftime("%Y%m%d%H%M%S")
  end
end
