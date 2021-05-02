module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class AnalyzerHelper
      def self.analize_packages(bin_path:, params:)
        return true if params[:skip_spm_analysis]

        path_to_report = "#{params[:output_directory]}/SwiftPackages"
        clean_reports_folder(path_to_report)
        params[:spm_checkouts_path] = resolve_package_dependencies(params)

        check_dependencies(
          params: params,
          bin_path: bin_path,
          path_to_report: path_to_report,
          destination: params[:spm_checkouts_path]
        )
      end

      def self.analize_pods(bin_path:, params:)
        return true if params[:skip_pods_analysis]

        path_to_report = "#{params[:output_directory]}/CocoaPods"
        clean_reports_folder(path_to_report)
        params[:pod_file_lock_path] = resolve_pods_dependencies(params)

        check_dependencies(
          params: params,
          bin_path: bin_path,
          path_to_report: path_to_report,
          destination: params[:pod_file_lock_path]
        )
      end

      private

      def self.clean_reports_folder(path)
        FileUtils.rm_rf(path)
        FileUtils.mkdir_p(path)
      end

      def self.check_dependencies(params:, bin_path:, path_to_report:, destination:)
        # Specify verbose output
        verbose = params[:verbose] ? " --log #{params[:verbose]}" : ''

        # Make the script executable
        Actions.sh("chmod 775 #{bin_path}")

        # Execute dependency-check
        begin
          Actions.sh(
            "#{bin_path}" \
              " --enableExperimental" \
              " --disableBundleAudit" \
              " --prettyPrint" \
              " --project #{params[:project_name]}" \
              " --out #{path_to_report}/report" \
              " --failOnCVSS #{params[:fail_on_cvss]}" \
              " --scan #{destination}" \
              "#{params[:output_types]}" \
              "#{verbose}"
          )
          true
        rescue
          false
        end
      end

      def self.parse_the_report(report)
        UI.crash!('There is no report to analyze. Consider reporting a bug.') if Dir[report].empty?

        JSON.parse(File.read(Dir[report].first))['runs'][0]['results'].size
      end

      def self.resolve_package_dependencies(params)
        return params[:spm_checkouts_path] if params[:spm_checkouts_path]

        UI.user_error!("xcodebuild not installed") if `which xcodebuild`.length.zero?

        checkouts_path = "#{params[:output_directory]}/SwiftPackages/checkouts"
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

      def self.resolve_pods_dependencies(params)
        return params[:pod_file_lock_path] if params[:pod_file_lock_path]

        UI.user_error!("pod not installed") if `which pod`.length.zero?

        if params[:project_path]
          Actions.sh("cd #{params[:project_path]} && set -o pipefail && pod install")
        else
          Actions.sh("set -o pipefail && pod install")
        end

        params[:project_path] ? "#{params[:project_path]}/Podfile.lock" : 'Podfile.lock'
      end
    end
  end
end
