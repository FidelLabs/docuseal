# frozen_string_literal: true

# Log configuration status on startup to verify .env variables are applied
Rails.application.config.after_initialize do
  logger = Rails.logger

  logger.info '=' * 80
  logger.info 'Configuration Status'
  logger.info '=' * 80

  # Storage Configuration
  storage_service = Rails.application.config.active_storage.service
  logger.info "Storage Service: #{storage_service}"
  
  if storage_service == :aws_s3
    bucket = ENV['S3_ATTACHMENTS_BUCKET']
    endpoint = ENV['AWS_ENDPOINT']
    region = ENV['AWS_REGION'] || 'us-east-1'
    public_access = ENV['ACTIVE_STORAGE_PUBLIC'] == 'true'
    
    logger.info "  └─ Bucket: #{bucket || 'NOT SET'}"
    logger.info "  └─ Endpoint: #{endpoint || 'AWS S3 (default)'}"
    logger.info "  └─ Region: #{region}"
    logger.info "  └─ Public Access: #{public_access ? 'ENABLED' : 'DISABLED'}"
  elsif storage_service == :disk
    logger.info "  └─ Using local disk storage"
  end

  # Email SMTP Configuration
  smtp_address = ENV['SMTP_ADDRESS']
  if smtp_address.present?
    logger.info "SMTP: CONFIGURED"
    logger.info "  └─ Address: #{smtp_address}"
    logger.info "  └─ Port: #{ENV.fetch('SMTP_PORT', '587')}"
    logger.info "  └─ Domain: #{ENV['SMTP_DOMAIN'] || 'NOT SET'}"
    logger.info "  └─ Username: #{ENV['SMTP_USERNAME'].present? ? 'SET' : 'NOT SET'}"
    logger.info "  └─ Password: #{ENV['SMTP_PASSWORD'].present? ? 'SET' : 'NOT SET'}"
  else
    logger.info "SMTP: NOT CONFIGURED (using #{Rails.application.config.action_mailer.delivery_method})"
  end

  # Redis Configuration
  redis_url = ENV['REDIS_URL']
  if redis_url.present?
    # Mask password in URL for security
    masked_url = redis_url.gsub(/(:\/\/[^:]+:)([^@]+)(@)/, '\1****\3')
    logger.info "Redis: CONFIGURED"
    logger.info "  └─ URL: #{masked_url}"
    
    # Test connection
    begin
      require 'redis'
      redis = Redis.new(url: redis_url)
      redis.ping
      logger.info "  └─ Connection: OK"
    rescue => e
      logger.warn "  └─ Connection: FAILED - #{e.message}"
    end
  else
    logger.info "Redis: NOT CONFIGURED"
  end

  # CDN Configuration
  cdn_url = ENV['CDN_URL'] || (Docuseal::CDN_URL if defined?(Docuseal))
  if cdn_url.present? && cdn_url != 'http://localhost:3000'
    logger.info "CDN: CONFIGURED"
    logger.info "  └─ URL: #{cdn_url}"
  else
    logger.info "CDN: NOT CONFIGURED (using default)"
  end

  logger.info '=' * 80
end

