module GoogleAnalytics
require 'google/api_client'

  def setup_google_analytics(_)
    
    @@client = Google::APIClient.new(
    :application_name => 'lita-ga',
    :application_version => '1.0')

    key = Google::APIClient::KeyUtils.load_from_pkcs12(config.key_path, 'notasecret')

    @@client.authorization = Signet::OAuth2::Client.new(
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    :audience => 'https://accounts.google.com/o/oauth2/token',
    :scope => 'https://www.googleapis.com/auth/analytics.readonly',
    :issuer => config.issuer,
    :signing_key => key)

    @@client.authorization.fetch_access_token!
    nil
  end

  def discovered_api
    @@client.discovered_api('analytics', 'v3')
  end

  def api_client
    @@client
  end

  def config
    Lita.config.handlers.ga
  end
end

