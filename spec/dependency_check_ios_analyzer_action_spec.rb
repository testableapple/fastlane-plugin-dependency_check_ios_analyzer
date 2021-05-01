describe Fastlane::Actions::DependencyCheckIosAnalyzerAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The dependency_check_ios_analyzer plugin is working!")

      Fastlane::Actions::DependencyCheckIosAnalyzerAction.run(nil)
    end
  end
end
