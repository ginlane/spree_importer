module Spree
  module Admin
    class OauthController < Spree::Admin::BaseController
      def check_google
        if spree_current_user.google_token.nil?
          render json: false and return
        end

        begin
          GoogleDrive.login_with_oauth spree_current_user.google_token
        rescue GoogleDrive::AuthenticationError
          render json: false and return
        end

        render json: true
      end

      def google
        url    = oauth_client.auth_code.authorize_url redirect_uri: redirect_uri,
                                                      scope: scopes
        if params[:redirect]
          session[:google_oauth_return_path] = params[:redirect]
        end

        redirect_to url
      end

      def google_redirect
        token = oauth_client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)

        spree_current_user.update_attribute :google_token, token.token
        spree_current_user.update_attribute :google_expires_at, Time.at(token.expires_at)

        flash[:notice] = "Authenticated with Google."
        redirect_to session.delete(:google_oauth_return_path)||admin_import_source_files_url
      end

      protected
      def client_id
        SpreeImporter.config.google_client_id
      end

      def client_secret
        SpreeImporter.config.google_client_secret
      end

      def redirect_uri
        "http://#{request.host_with_port}/admin/auth/google_redirect"
      end

      def scopes
        %w[ https://docs.google.com/feeds/
            https://docs.googleusercontent.com/
            https://spreadsheets.google.com/feeds/ ].join(" ")
      end

      def oauth_client
        @oauth_client ||=  ::OAuth2::Client.new client_id, client_secret,
                                    site: "https://accounts.google.com",
                                    token_url: "/o/oauth2/token",
                                    authorize_url: "/o/oauth2/auth"
      end
    end
  end
end
