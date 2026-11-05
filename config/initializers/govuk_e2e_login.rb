if Rails.env.development? && ENV["SIGN_IN_AS_GOVUK_E2E_USER"] == "true"
  Warden::Manager.on_request do |_proxy|
    e2e_user =
      GDS::SSO::Config.user_klass.find_by(
        uid: GovukE2e::ContentBlockManager::Fixtures::E2E_USER_UID,
      )
    GDS::SSO.test_user = e2e_user if e2e_user
  end
end
