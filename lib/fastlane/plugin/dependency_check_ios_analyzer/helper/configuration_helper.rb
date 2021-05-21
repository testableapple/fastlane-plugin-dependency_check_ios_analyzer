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
        version = params[:cli_version] ? params[:cli_version] : '6.1.6'
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

          if params[:verify_integrity]
            verify_cryptographic_integrity(zip_path: zip_path, base_url: base_url)
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

      def self.verify_cryptographic_integrity(zip_path:, base_url:)
        asc_url = "#{base_url}.zip.asc"
        UI.message("🚀 Downloading associated GPG signature file: #{asc_url}")
        curl = Curl.get(asc_url) { |curl| curl.follow_location = true }

        asc_path = "#{zip_path}.asc"
        File.open(asc_path, 'w+') { |f| f.write(curl.body_str) }

        # https://jeremylong.github.io/DependencyCheck/dependency-check-cli/
        gpg_key = 'F9514E84AE3708288374BBBE097586CFEA37F9A6'

        UI.message("🕵️  Verifying the cryptographic integrity")
        # Import the GPG key used to sign all DependencyCheck releases
        Actions.sh("gpg --keyserver hkp://keys.gnupg.net --recv-keys #{gpg_key}")
        # Verify the cryptographic integrity
        Actions.sh("gpg --verify #{asc_path}")

        FileUtils.rm_rf(asc_path)
      end
    end
  end
end
