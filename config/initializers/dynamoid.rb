Dynamoid.configure do |config|
  config.access_key = ENV["AWS_ACCESS_KEY_ID"]
  config.secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
  config.region = ENV.fetch("AWS_REGION", "us-east-1")
  config.namespace = "litlink_prod" # Para ambiente de producción
end
