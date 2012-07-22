module Facebook
  CONFIG = YAML.load_file(Rails.root.to_s + "/config/facebook.yml")[Rails.env]
  APP_ID = CONFIG['app_id']
  APP_SECRET = CONFIG['app_secret']
  SCOPE = CONFIG['scope']
end
