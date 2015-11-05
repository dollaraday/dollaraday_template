Rails.application.config.paperclip_defaults = {
  path: "images/:attachment/:id/:style.:extension",
  default_url: ":attachment/:style/missing.png",
  storage: :s3,
  s3_protocol: Rails.env.development? ? :http : :https,
  s3_permissions: :public_read,
  s3_credentials: {
    :bucket => S3[:bucket],
    :access_key_id => S3[:access_key_id],
    :secret_access_key => S3[:secret_access_key]
  },
  bucket: S3[:bucket]
}

# To use the CF hostname instead of S3
Rails.application.config.paperclip_defaults[:s3_host_alias] = Rails.application.config.action_controller.asset_host # CF?

# We don't need CF on development
Rails.application.config.paperclip_defaults[:url] = ":s3_alias_url" if !Rails.env.development?
