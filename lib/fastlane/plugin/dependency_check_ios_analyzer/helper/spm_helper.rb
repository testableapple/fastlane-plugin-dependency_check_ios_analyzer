module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SpmHelper
      def self.analize(bin_path:, params:)
        if params[:skip_spm_analysis]
          UI.important("⚡ SPM dependencies will NOT be analyzed.")
          return 0
        end

        # Verify xcodebuild
        UI.user_error!("xcodebuild not installed") if `which xcodebuild`.length.zero?

        # Specify verbose output
        verbose = params[:verbose] ? " --log #{params[:verbose]}" : ''

        # Resolve package ddependencies
        checkouts_path = resolve_package_dependencies(params)

        # Make the script executable
        Actions.sh("chmod 775 #{bin_path}")

        # Execute DependencyCheck
        begin
          Actions.sh(
            "#{bin_path}" \
              " --enableExperimental" \
              " --disableBundleAudit" \
              " --prettyPrint" \
              " --project #{params[:project_name]}" \
              " --out #{params[:output_directory]}/SPM/report" \
              " --failOnCVSS #{params[:fail_on_cvss]}" \
              " --scan #{checkouts_path}" \
              "#{params[:output_types]}" \
              "#{verbose}"
          )
        rescue
          return false
        end

        true
      end

      private

      def self.resolve_package_dependencies(params)
        return params[:spm_checkouts_path] if params[:spm_checkouts_path]

        checkouts_path = "#{params[:output_directory]}/SPM/SourcePackages"
        checkouts_path = "#{Dir.pwd}/#{checkouts_path}" unless params[:output_directory].include?(Dir.pwd)

        if params[:project_path]
          Actions.sh("cd #{params[:project_path]} && " \
                     "set -o pipefail && " \
                     "xcodebuild -resolvePackageDependencies -clonedSourcePackagesDirPath #{checkouts_path}")
        else
          Actions.sh("set -o pipefail && " \
                     "xcodebuild -resolvePackageDependencies -clonedSourcePackagesDirPath #{checkouts_path}")
        end

        UI.message("🎉 SPM checkouts path: #{checkouts_path}")
        checkouts_path
      end
    end
  end
end
