# frozen_string_literal: true

class PlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stripe_key
  skip_authorization_check

  def index
    @stripe_publishable_key = ENV['STRIPE_PUBLISHABLE_KEY']
    @stripe_customer_id = current_account.subscription&.stripe_customer_id
    @current_subscription = current_account.subscription
  end

  def create_checkout_session
    plan_type = params[:plan_type]
    return render json: { error: 'Invalid plan type' }, status: :bad_request unless %w[pro enterprise].include?(plan_type)

    if plan_type == 'enterprise'
      redirect_to 'https://signpaw.com/contactus', allow_other_host: true
      return
    end

    # Pro plan - create Stripe checkout session
    customer_id = current_account.subscription&.stripe_customer_id

    session_params = {
      mode: 'subscription',
      line_items: [{
        price: ENV["STRIPE_#{plan_type.upcase}_PRICE_ID"],
        quantity: 1
      }],
      success_url: "#{request.base_url}/plans/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{request.base_url}/plans",
      customer: customer_id,
      customer_email: customer_id ? nil : current_user.email,
      metadata: {
        account_id: current_account.id,
        account_uuid: current_account.uuid,
        plan_type: plan_type
      }
    }.compact

    checkout_session = Stripe::Checkout::Session.create(session_params)

    render json: { checkout_url: checkout_session.url }
  rescue Stripe::StripeError => e
    Rollbar.error(e) if defined?(Rollbar)
    render json: { error: e.message }, status: :bad_request
  end

  def success
    session_id = params[:session_id]
    return redirect_to plans_path, alert: 'Invalid session' if session_id.blank?

    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    return redirect_to plans_path, alert: 'Session not found' unless checkout_session

    # Store minimal info - Stripe manages everything else via Customer Portal
    subscription = current_account.subscription || current_account.build_subscription
    subscription.update!(
      stripe_customer_id: checkout_session.customer,
      stripe_subscription_id: checkout_session.subscription,
      plan_type: checkout_session.metadata['plan_type'] || 'pro'
    )

    redirect_to plans_path, notice: 'Subscription activated successfully!'
  rescue Stripe::StripeError => e
    Rollbar.error(e) if defined?(Rollbar)
    redirect_to plans_path, alert: "Error processing subscription: #{e.message}"
  end

  def create_portal_session
    customer_id = current_account.subscription&.stripe_customer_id
    if customer_id.blank?
      if request.format.json?
        return render json: { error: 'No active subscription found' }, status: :not_found
      end
      return redirect_to plans_path, alert: 'No active subscription found'
    end

    portal_session = Stripe::BillingPortal::Session.create(
      customer: customer_id,
      return_url: plans_url
    )

    if request.format.json?
      render json: { portal_url: portal_session.url }
    else
      redirect_to portal_session.url, allow_other_host: true
    end
  rescue Stripe::StripeError => e
    Rollbar.error(e) if defined?(Rollbar)
    if request.format.json?
      render json: { error: e.message }, status: :bad_request
    else
      redirect_to plans_path, alert: "Error accessing billing portal: #{e.message}"
    end
  end

  def contact
    redirect_to 'https://signpaw.com/contactus', allow_other_host: true
  end

  private

  def set_stripe_key
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  end
end

