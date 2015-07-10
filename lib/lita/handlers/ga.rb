require 'lita-ga/google_analytics'
module Lita
  module Handlers
    class Ga < Handler
      include GoogleAnalytics
      config :key_path
      config :issuer

      on :loaded, :setup_google_analytics

      route(/^unique_views/, :unique_views, command: false, help: { "unique_views" => "Returns unique views for last 24 hours."})

      route(/^top_referrers\s?(\d{1,3})?/, :top_referrers, command: false, help: { "top_referrers" => "Returns the top referrers for the last 24 hours."})
      
      def unique_views(response)
        response.reply "There were #{get_unique_views} unique views in the last 24 hours."
      end

      def top_referrers(response)
        @places = response.matches[0][0].to_i
        response.reply "Top Referrers:\n#{get_top_referrers}"
      end

      private

      def get_unique_views
        @google_analytics_api = discovered_api
        result = api_client.execute( :api_method => @google_analytics_api.data.ga.get,
        parameters: { 'ids' => 'ga:66662181', 'start-date' => 'yesterday', 'end-date' => 'today', 'metrics' => 'ga:users' })
        result.data.totalsForAllResults["ga:users"]
      end

      def get_top_referrers
        @google_analytics_api = discovered_api
        result = api_client.execute( :api_method => @google_analytics_api.data.ga.get,
        parameters: { 'ids' => 'ga:66662181', 'start-date' => 'yesterday', 'end-date' => 'today', 'metrics' => 'ga:users', 'dimensions' => 'ga:source' })
        referrers = result.data.rows.map! { |a| [ a[0], a[1].to_i ] }
        sorted = referrers.sort! {|a,b| b[1] <=> a[1]}.map { |row| row.join(" - ")}
        sorted[0..@places].join("\n")
      end

    end

    Lita.register_handler(Ga)
  end
end

