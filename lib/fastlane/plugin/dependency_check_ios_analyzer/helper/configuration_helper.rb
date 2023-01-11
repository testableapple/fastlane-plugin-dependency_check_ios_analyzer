require 'json'
require 'curb'
require 'zip'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class ConfigurationHelper
      def self.install(params)
        repo = 'https://github.com/jeremylong/DependencyCheck'
        name = 'dependency-check'
        version = params[:cli_version] ? params[:cli_version] : '7.4.4'
        base_url = "#{repo}/releases/download/v#{version}/#{name}-#{version}-release"
        bin_path = "#{params[:output_directory]}/#{name}/bin/#{name}.sh"
        zip_path = "#{params[:output_directory]}/#{name}.zip"

        unless File.exist?(bin_path)
          FileUtils.mkdir_p(params[:output_directory])

          unless File.exist?(zip_path)
            zip_url = "#{base_url}.zip"
            UI.message("🚀 Downloading DependencyCheck: #{zip_url}")
            curl = Curl.get(zip_url) { |curl| curl.follow_location = true }
            File.open(zip_path, 'w+') { |f| f.write(curl.body_str) }
          end

          unzip(file: zip_path, params: params)

          FileUtils.rm_rf(zip_path)
        end

        bin_path
      end

      def self.parse_output_types(output_types)
        list = output_types.delete(' ').split(',')
        list << 'sarif' unless output_types =~ (/(sarif|all)/)
        report_types = ''
        list.each { |output_type| report_types += " --format #{output_type.upcase}" }

        UI.message("🎥 Output types: #{list}")
        report_types
      end

      def self.clean_up(params)
        return if params[:keep_binary_on_exit]

        FileUtils.rm_rf("#{params[:output_directory]}/dependency-check")
      end

      private

      def self.unzip(file:, params:)
        Zip::File.open(file) do |zip_file|
          zip_file.each do |f|
            fpath = File.join(params[:output_directory], f.name)
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
      end
    end
  end
end
