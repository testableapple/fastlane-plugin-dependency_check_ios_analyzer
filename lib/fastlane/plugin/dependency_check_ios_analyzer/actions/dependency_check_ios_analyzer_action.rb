require 'fastlane_core/ui/ui'
require 'fastlane/action'
require_relative '../helper/configuration_helper'
require_relative '../helper/analyzer_helper'

module Fastlane
  module Actions
    class DependencyCheckIosAnalyzerAction < Action
      def self.run(params)
        params[:output_types] = Helper::ConfigurationHelper.parse_output_types(params[:output_types])
        bin_path = Helper::ConfigurationHelper.install(params)

        spm_analysis = Helper::AnalyzerHelper.analize_packages(bin_path: bin_path, params: params)
        pods_analysis = Helper::AnalyzerHelper.analize_pods(bin_path: bin_path, params: params)

        on_exit(params: params, result: (spm_analysis && pods_analysis))
      end

      def self.on_exit(params:, result:)
        Helper::ConfigurationHelper.clean_up(params)
        say_goodbye = '✨ Check out the report for further investigation.'
        result ? UI.important(say_goodbye) : UI.user_error!(say_goodbye)
      end

      #####################################################
      #                   Documentation                   #
      #####################################################

      def self.description
        'Fastlane wrapper around the OWASP dependency-check iOS analyzers (Swift Package Manager and CocoaPods).'
      end

      def self.authors
        ["Alexey Alter-Pesotskiy"]
      end

      def self.example_code
        [
          dependency_check_ios_analyzer(
            project_name: 'SampleProject',
            output_types: 'html, junit',
            fail_on_cvss: 3
          )
        ]
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
            description: 'Path to Swift Packages, if resolved',
            optional: true,
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :pod_file_lock_path,
            description: 'Path to the Podfile.lock file, if exists',
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
            default_value: 'sarif',
            is_string: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :cli_version,
            description: 'Overwrite the version of DependencyCheck analyzer',
            optional: true,
            is_string: true,
            default_value: '10.0.3',
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
          ),
          FastlaneCore::ConfigItem.new(
            key: :suppression,
            description: 'Path to suppression file',
            optional: true,
            is_string: true,
            type: String
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
