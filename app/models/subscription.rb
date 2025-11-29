# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                     :bigint           not null, primary key
#  plan_type              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :bigint           not null
#  stripe_customer_id     :string
#  stripe_subscription_id :string
#
# Indexes
#
#  index_subscriptions_on_account_id              (account_id)
#  index_subscriptions_on_plan_type               (plan_type)
#  index_subscriptions_on_stripe_customer_id      (stripe_customer_id) UNIQUE
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Subscription < ApplicationRecord
  PLAN_TYPES = %w[pro enterprise].freeze

  belongs_to :account

  validates :plan_type, inclusion: { in: PLAN_TYPES }, allow_nil: true
  validates :stripe_customer_id, uniqueness: true, allow_nil: true

  scope :pro, -> { where(plan_type: 'pro') }
  scope :enterprise, -> { where(plan_type: 'enterprise') }

  # Simple check - if customer_id exists, assume active
  # Stripe Customer Portal handles cancellations, so if customer exists, subscription is managed by Stripe
  def active?
    stripe_customer_id.present?
  end

  def pro?
    plan_type == 'pro' && active?
  end

  def enterprise?
    plan_type == 'enterprise' && active?
  end
end
