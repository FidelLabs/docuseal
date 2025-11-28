# frozen_string_literal: true

module RateLimit
  LimitApproached = Class.new(StandardError)

  @redis_client = nil

  module_function

  def redis_client
    @redis_client ||= begin
      redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
      RedisClient.new(url: redis_url)
    end
  end

  def call(key, limit:, ttl:, enabled: Docuseal.multitenant?)
    return true unless enabled

    # Use Redis INCR with expiration for rate limiting
    # This works across multiple instances
    rate_limit_key = "rate_limit:#{key}"
    current_value = redis_client.call('INCR', rate_limit_key)

    # Set expiration on first increment
    redis_client.call('EXPIRE', rate_limit_key, ttl) if current_value == 1

    raise LimitApproached if current_value > limit

    true
  rescue RedisClient::Error => e
    # Fallback: allow request if Redis is unavailable
    # Log error but don't block requests
    Rails.logger.error("RateLimit Redis error: #{e.message}") if defined?(Rails)
    true
  end
end
