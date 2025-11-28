# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  around_action :with_browser_locale

  def new
    build_resource({})
    @account = Account.new
    super
  end

  def create
    build_resource(sign_up_params)

    # Create account for multitenant mode
    if Docuseal.multitenant?
      account_name = sign_up_params[:email]&.split('@')&.first&.capitalize || 'My Account'
      @account = Account.new(name: account_name)
      @account.timezone = Accounts.normalize_timezone('UTC')
      @account.locale = I18n.locale.to_s
      
      unless @account.valid?
        @account.errors.full_messages.each { |msg| resource.errors.add(:base, msg) }
        clean_up_passwords resource
        set_minimum_password_length
        return render :new
      end
    end

    ApplicationRecord.transaction do
      if Docuseal.multitenant?
        @account.save!
        resource.account = @account
      end

      if resource.save
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
        raise ActiveRecord::Rollback
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :password_confirmation])
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def with_browser_locale(&)
    super(&) if defined?(super)
  end
end

