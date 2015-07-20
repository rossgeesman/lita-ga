require 'lita-ga/google_analytics'
module Lita
  module Handlers
    class Ga < Handler
      include GoogleAnalytics
      config :key_path
      config :issuer

      on :loaded, :setup_google_analytics

      route(/^unique_views\s([0-9]{4}-[0-9]{2}-[0-9]{2}){1}\s([0-9]{4}-[0-9]{2}-[0-9]{2}){1}\s?(week|month|year)?/, :unique_views, command: false, help: 
        { "unique_views" => "Returns unique users for a given period and compares it with the previous 
          period. Commands follow the format: unique_views START-DATE END-DATE COMPARISON-PERIOD. 
          Options for comparison inlude week, month, and year. EX) unique_views 1995-06-01 1995-07-01 year"})

      route(/^top_referrers\s?(\d{1,3})?/, :top_referrers, command: false, help: { "top_referrers" => "Returns the top referrers for the last 24 hours."})
      
      def unique_views(response)
        @unique_views = get_unique_views(start_date: response.match_data[1], end_date: response.match_data[2], comparison: response.match_data[3])
        
        response_string = "#{@unique_views[0][0][0]} - #{@unique_views[0][0][1]}: #{@unique_views[0][1]}" 
        if @unique_views[1]
          response.reply response_string + " VS #{@unique_views[1][0][0]} - #{@unique_views[1][0][1]}: #{@unique_views[1][1]}"
        else
          response.reply response_string 
        end
      end
      
      def top_referrers(response)
        @places = response.matches[0][0].to_i
        response.reply "Top Referrers:\n#{get_top_referrers}"
      end

      private

      def get_unique_views(start_date: ,end_date: ,comparison: nil)
        cleaned_start_date = Date.parse start_date
        cleaned_end_date = Date.parse end_date
        full_response = []
        #get views between start data and end date
        full_response << [[cleaned_start_date, cleaned_end_date], query_views(start_date: cleaned_start_date.to_s, end_date: cleaned_end_date.to_s)]
        unless comparison.nil?  
          case comparison 
          when "week"
            full_response << [[cleaned_start_date - 7, cleaned_end_date - 7], query_views(start_date: (cleaned_start_date - 7).to_s, end_date: (cleaned_end_date - 7).to_s) ]
          when "month"
            full_response << [[cleaned_start_date.prev_month, cleaned_end_date.prev_month], query_views(start_date: (cleaned_start_date.prev_month).to_s, end_date: (cleaned_end_date.prev_month).to_s) ]
          when "year"
            full_response << [[cleaned_start_date.prev_year, cleaned_end_date.prev_year], query_views(start_date: (cleaned_start_date.prev_year).to_s, end_date: (cleaned_end_date.prev_year).to_s) ]
          else
            return "Your input for the comparison was invalid. Please use 'week', 'month', or 'year'."
          end
        end
        full_response
      end

      def query_views(start_date: ,end_date: )
        views = {period: nil , views: nil}

        @google_analytics_api = discovered_api
        result = api_client.execute( :api_method => @google_analytics_api.data.ga.get,
        parameters: { 'ids' => 'ga:66662181', 'start-date' => start_date, 'end-date' => end_date, 'metrics' => 'ga:users' })
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

