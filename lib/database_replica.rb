# frozen_string_literal: true

# Helper module for using database read replicas
# Usage:
#   DatabaseReplica.with_replica do
#     User.where(account_id: 1).find_each { |u| ... }
#   end
module DatabaseReplica
  module_function

  # Execute a block using the read replica connection (if configured)
  # Falls back to primary database if replica is not configured
  def with_replica(&block)
    if replica_configured?
      ActiveRecord::Base.connected_to(role: :reading, &block)
    else
      yield
    end
  end

  # Check if read replica is configured
  def replica_configured?
    return false unless Rails.env.production?

    ENV['DATABASE_REPLICA_URL'].present? && ENV['DATABASE_REPLICA_URL'].match?(/\Apostgres/)
  end

  # Execute a block using the primary (write) connection
  # This is the default behavior, but can be used explicitly
  def with_primary(&block)
    ActiveRecord::Base.connected_to(role: :writing, &block)
  end
end

