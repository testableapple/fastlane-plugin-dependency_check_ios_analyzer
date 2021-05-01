# fastlane-plugin-dependency_check_ios_analyzer

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-dependency_check_ios_analyzer)

## About dependency_check_ios_analyzer

Fastlane wrapper around the [OWASP dependency-check](https://jeremylong.github.io/DependencyCheck) iOS analyzers ([Swift Package Manager](https://jeremylong.github.io/DependencyCheck/analyzers/swift.html) and [CocoaPods](https://jeremylong.github.io/DependencyCheck/analyzers/cocoapods.html)).

This analyzer is considered experimental. While it may be useful and provide valid results more testing must be completed to ensure that the false negative/false positive rates are acceptable.

## Parameters

| **Key** | **Description** | **Default** |
| ------- |---------------- | ----------- |
| `skip_spm_analysis` | Skip analysis of `SPM` dependencies | `false` |
| `skip_pods_analysis` | Skip analysis of `CocoaPods` dependencies | `false` |
| `spm_checkouts_path` | Path to Swift Packages, if they are resolved | |
| `pod_file_lock_path` | Path to the `Podfile.lock` file. **Not implemented yet** | |
| `project_path` | Path to the directory that contains an Xcode project, workspace or package. Defaults to the `root` | |
| `project_name` | The project's name | `DependencyCheck` |
| `output_directory` | The directory in which all reports will be stored | `dependency-check` |
| `output_types` | Comma separated list of the output types (e.g. `html`, `xml`, `csv`, `json`, `junit`, `sarif`, `all`) | `sarif` |
| `cli_version` | Overwrite the version of `DependencyCheck` analyzer | `6.1.6` |
| `gpg_key` | Overwrite the GPG key to verify the cryptographic integrity of the requested `cli_version` | |
| `verbose` | The file path to write verbose logging information | |
| `fail_on_cvss` | Specifies if the build should be failed if a CVSS score above a specified level is identified. Since the CVSS scores are 0-10, by default the build will never fail | `11` |
| `junit_fail_on_cvss` | Specifies the CVSS score that is considered a failure when generating the junit report | `0` |
| `keep_binary_on_exit` | Keep `DependencyCheck` binary and data on exit | `true` |

## Requirements

* [Xcode](https://developer.apple.com/downloads)
* [Xcode Command Line Tools](http://railsapps.github.io/xcode-command-line-tools.html)

## Getting Started

To get started with `dependency_check_ios_analyzer`, add it to your project by running:

```bash
$ fastlane add_plugin dependency_check_ios_analyzer
```

## Usage

```ruby
vulnerabilities_count = dependency_check_ios_analyzer(
  output_types: 'html, junit',
  fail_on_cvss: 7
)
```

## How to read the reports

* [Docs](https://jeremylong.github.io/DependencyCheck/general/thereport.html)
