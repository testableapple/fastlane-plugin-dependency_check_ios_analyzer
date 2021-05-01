module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class PodsHelper
      def self.analize(params)
        if params[:skip_pods_analysis]
          UI.important("⚡ Cocoapods dependencies will NOT be analyzed.")
          return 0
        end

        0 # FIXME: https://github.com/alteral/fastlane-plugin-dependency_check_ios_analyzer/issues/3
      end

      private

      def self.verify(params)
        report = "#{params[:output_directory]}/Cocoapods/*.sarif"
        if Dir[report].empty?
          UI.crash!('Something went wrong. There is no report to analyze. Consider reporting a bug.')
        end

        JSON.parse(File.read(Dir[report].first))
      end
    end
  end
end
