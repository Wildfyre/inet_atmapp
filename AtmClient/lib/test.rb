require 'yaml'

settings = YAML::load_file "langs.yml"
puts settings.inspect