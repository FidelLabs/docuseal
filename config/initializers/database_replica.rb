# frozen_string_literal: true

# Configure database read replicas if DATABASE_REPLICA_URL is set
# This enables using ActiveRecord::Base.connected_to(role: :reading) for read-only queries
if Rails.env.production? && ENV['DATABASE_REPLICA_URL'].present? && ENV['DATABASE_REPLICA_URL'].match?(/\Apostgres/)
  Rails.application.configure do
    # Enable automatic read/write splitting (optional - can be done manually)
    # config.active_record.reads = true
    # config.active_record.database_selector = { delay: 2.seconds }
    # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
    # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
  end

  # Define the replica connection using Rails 6+ multiple databases API
  ActiveRecord::Base.connects_to(
    database: {
      writing: :primary,
      reading: :replica
    }
  )
end

