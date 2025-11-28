# frozen_string_literal: true

class DashboardController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  before_action :redirect_to_sign_in_unless_authenticated
  before_action :maybe_redirect_mfa_setup

  skip_authorization_check

  def index
    if cookies.permanent[:dashboard_view] == 'submissions'
      SubmissionsDashboardController.dispatch(:index, request, response)
    else
      TemplatesDashboardController.dispatch(:index, request, response)
    end
  end

  private

  def redirect_to_sign_in_unless_authenticated
    return if signed_in?
    # Don't redirect if already on sign in page (prevents redirect loop)
    return if request.path == new_user_session_path

    # Redirect to sign in page if not authenticated
    redirect_to new_user_session_path
  end

  def maybe_redirect_mfa_setup
    return unless signed_in?
    return if current_user.otp_required_for_login

    return if !current_user.otp_required_for_login && !AccountConfig.exists?(value: true,
                                                                             account_id: current_user.account_id,
                                                                             key: AccountConfig::FORCE_MFA)

    redirect_to mfa_setup_path, notice: I18n.t('setup_2fa_to_continue')
  end

end
