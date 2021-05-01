require 'fastlane_core/ui/ui'
require 'fastlane/action'
require_relative '../helper/analyzer_helper'
require_relative '../helper/pods_helper'
require_relative '../helper/spm_helper'

module Fastlane
  module Actions
    class DependencyCheckIosAnalyzerAction < Action
      def self.run(params)
        params[:output_types] = Helper::AnalyzerHelper.parse_output_types(params[:output_types])
        bin_path = Helper::AnalyzerHelper.install(params)
        @success = Helper::SpmHelper.analize(bin_path: bin_path, params: params)
        @vulnerabilities = Helper::AnalyzerHelper.parse_report("#{params[:output_directory]}/SPM/report/*.sarif")
        on_exit(params)
      end

      def self.on_exit(params)
        Helper::AnalyzerHelper.clean_up(params)
        say_goodbye = "🦠 There are #{@vulnerabilities} potential vulnerabilities. " \
                      'Check out the report for further investigation.'
        @success ? UI.important(say_goodbye) : UI.crash!(say_goodbye)
      end

      #####################################################
      #                   Documentation                   #
      #####################################################

      def self.description
        'Fastlane wrapper around the OWASP dependency-check Swift Package Manager and Cocoapods analyzers.'
      end

      def self.authors
        ["Alexey Alter-Pesotskiy"]
      end

      def self.example_code
        [
          vulnerabilities_count = dependency_check_ios_analyzer(
            project_name: 'SampleProject',
            skip_pods_analysis: true,
            output_types: 'html, junit',
            fail_on_cvss: 7
          )
        ]
      end

      def self.return_value
        @vulnerabilities
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :skip_spm_analysis,
            description: 'Skip analysis of SPM dependencies',
            optional: true,
            default_value: false,
            is_string: false,
            type: Boolean
          ),
          FastlaneCore::ConfigItem.new(
            key: :skip_pods_analysis,
            description: 'Skip analysis of CocoaPods dependencies',
            optional: true,
            default_value: false,
            is_string: false,
            type: Boolean
          ),
          FastlaneCore::ConfigItem.new(
            key: :spm_checkouts_path,
            description: 'Path to Swift Packages, if they are resolved',
            optional: true,
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :pod_file_lock_path,
            description: 'Path to the Podfile.lock file',
            optional: true,
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :project_path,
            description: 'Path to the directory that contains an Xcode project, workspace or package. Defaults to root',
            optional: true,
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :project_name,
            description: "The project's name",
            optional: true,
            default_value: 'DependencyCheck',
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_directory,
            description: 'The directory in which all reports will be stored',
            optional: true,
            default_value: 'dependency-check',
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_types,
            description: 'Comma separated list of the output types (e.g. html, xml, csv, json, junit, sarif, all)',
            optional: true,
            default_value: 'SARIF',
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :cli_version,
            description: 'Specify the required version of DependencyCheck analyzer. Not recommended',
            optional: true,
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :rsa_key,
            description: 'Specify the RSA_KEY of DependencyCheck analyzer download. Not recommended',
            optional: true,
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :verbose,
            description: 'The file path to write verbose logging information',
            optional: true,
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :fail_on_cvss,
            description: 'Specifies if the build should be failed if a CVSS score above a specified level is identified. ' \
                         'Since the CVSS scores are 0-10, by default the build will never fail',
            optional: true,
            default_value: 11,
            is_string: false,
            type: Integer
          ),
          FastlaneCore::ConfigItem.new(
            key: :junit_fail_on_cvss,
            description: 'Specifies the CVSS score that is considered a failure when generating the junit report',
            optional: true,
            default_value: 0,
            is_string: false,
            type: Integer
          ),
          FastlaneCore::ConfigItem.new(
            key: :keep_binary_on_exit,
            description: 'Keep DependencyCheck binary and data on exit',
            optional: true,
            default_value: true,
            is_string: false,
            type: Boolean
          )
        ]
      end

      def self.category
        :testing
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
