module Coast
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      
      desc "Copy locale files to your application."

      def copy_locale
        copy_file "locales/en.yml", "config/locales/coast.en.yml"
      end
    end
  end
end