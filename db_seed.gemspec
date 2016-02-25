Gem::Specification.new do |s|
  s.name        = 'db_seed'
  s.version     = '0.0.1'
  s.date        = '2016-02-25'
  s.summary     = "More than just db:migrate, db:migrate:seed"
  s.description = "Add ability to migrate data, separately from schema"
  s.authors     = ["Tangerine Cat"]
  s.email       = 'kaineer@gmail.com'
  s.files       = IO.read("./Manifest.txt").split($/).reject do |line|
    /^(\s*|#.*)$/ === line
  end
  s.homepage    = 'http://bitbucket.org/sdelki24/db_seed'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec'
end
