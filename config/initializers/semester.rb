module DefaultSemester
  CONFIG = YAML.load_file(Rails.root.to_s + "/config/semester.yml")
  YEAR = CONFIG['year']
  SEASON = CONFIG['season']
end
