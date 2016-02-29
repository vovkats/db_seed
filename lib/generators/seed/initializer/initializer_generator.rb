module Seed
  class InitializerGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def create_initializer
      template "initializer.rb.erb", "config/initializers/dbseed.rb"
    end
  end
end
