require "yaml"

module Strata
  module CLI
    class Credentials
      include Thor::Shell

      # Retrieve existing credentials for the
      # given ds_key or empty hash.
      def self.fetch(ds_key)
        CLI.config[ds_key] || {}
      end

      attr_reader :adapter
      attr_reader :credentials
      def initialize(adapter)
        @adapter = adapter.downcase.strip
      end

      def required?
        adapter != "duckdb"
      end

      def collect
        credentials = {}

        case adapter
        when "snowflake"
          auth_mode = ask("Authentication mode (pat/kp/oauth):", default: "pat")
          credentials["auth_mode"] = auth_mode

          case auth_mode
          when "pat"
            credentials["personal_access_token"] = ask("Personal Access Token:")
          when "kp"
            credentials["username"] = ask("Username:")
            credentials["private_key"] = ask("Private Key Path:")
          when "oauth"
            credentials["oauth_client_id"] = ask("OAuth Client ID:")
            credentials["oauth_client_secret"] = ask("OAuth Client Secret:")
            credentials["oauth_redirect_uri"] = ask("OAuth Redirect URI:", default: "https://localhost:3420/callback")
            oauth_scope = ask("OAuth Scope (optional):")
            credentials["oauth_scope"] = oauth_scope unless oauth_scope.empty?
          end
        when "athena"
          credentials["access_key_id"] = ask("AWS Access Key ID:")
          credentials["secret_access_key"] = ask("AWS Secret Access Key:")
        else
          if required?
            credentials["username"] = ask("Username:")
            credentials["password"] = ask("Password:")
          end
        end

        @credentials = credentials
      end

      def collected?
        !@credentials.keys.empty?
      end

      def write_local(ds_key, context)
        context.gsub_file Configuration::CONFIG_FILE, Utils.yaml_block_matcher(ds_key), ""
        creds = "#{ds_key}:"
        credentials.each do |key, val|
          creds << "\n  #{key}: #{val}" unless val.blank?
        end

        context.append_to_file Strata::CLI::Configuration::CONFIG_FILE, creds
      end
    end
  end
end
