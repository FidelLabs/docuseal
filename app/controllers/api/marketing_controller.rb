# frozen_string_literal: true

class Api::MarketingController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  before_action :set_cors_headers

  # GET /api/marketing/stats
  # Returns public statistics for marketing site
  def stats
    render json: {
      total_users: User.count,
      total_documents: Submission.count,
      total_templates: Template.count,
      version: Docuseal.version,
      updated_at: Time.current.iso8601
    }
  end

  # GET /api/marketing/health
  # Health check endpoint
  def health
    render json: {
      status: 'ok',
      version: Docuseal.version,
      timestamp: Time.current.iso8601
    }
  end

  # GET /api/marketing/features
  # Returns feature list (can be customized)
  def features
    render json: {
      features: [
        {
          name: 'Easy to Start',
          description: 'Run on your own host using Docker container, or deploy on your favorite managed PaaS.',
          icon: 'brand_docker'
        },
        {
          name: 'Mobile Optimized',
          description: 'Review and sign digital documents online from any device.',
          icon: 'devices'
        },
        {
          name: 'Secure',
          description: 'Host it on your hardware under a VPN to ensure that important documents can be accessed only within your organization.',
          icon: 'shield_check'
        },
        {
          name: 'Open Source',
          description: 'Source code is available under GitHub. Open-source contributors are always ready to help!',
          icon: 'brand_github'
        }
      ]
    }
  end

  private

  def set_cors_headers
    # Allow requests from marketing site
    marketing_domain = Docuseal::PRODUCT_URL&.gsub(%r{https?://}, '')&.gsub(%r{/.*}, '')
    origin = request.headers['Origin']
    
    if origin.present? && (origin.include?(marketing_domain.to_s) || Rails.env.development?)
      headers['Access-Control-Allow-Origin'] = origin
      headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Content-Type, Accept'
      headers['Access-Control-Max-Age'] = '3600'
    end
  end
end

