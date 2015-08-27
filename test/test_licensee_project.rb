require 'helper'
require 'fileutils'

class TestLicenseeProject < Minitest::Test

  [true, false].each do |as_git|
    describe(as_git ? "git" : "non-git") do

      def make_project(fixture_name, as_git)
        fixture = fixture_path fixture_name

        unless as_git
          dest = File.join("tmp", "fixtures", fixture_name)
          FileUtils.mkdir_p File.dirname(dest)
          system "git", "clone", "-q", fixture, dest
          FileUtils.rm_r File.join(dest, ".git")
          fixture = dest
        end

        Licensee::Project.new fixture
      end

      unless as_git
        def teardown
          FileUtils.rm_rf "tmp/fixtures"
        end
      end

      should "detect the license file" do
        project = make_project "licenses.git", as_git
        assert_instance_of Licensee::ProjectFile, project.license_file
      end

      should "detect the license" do
        project = make_project "licenses.git", as_git
        assert_equal "mit", project.license.key
      end

      should "detect an atypically cased license file" do
        project = make_project "case-sensitive.git", as_git
        assert_instance_of Licensee::ProjectFile, project.license_file
      end

      should "detect MIT-LICENSE licensed projects" do
        project = make_project "named-license-file-prefix.git", as_git
        assert_equal "mit", project.license.key
      end

      should "detect LICENSE-MIT licensed projects" do
        project = make_project "named-license-file-suffix.git", as_git
        assert_equal "mit", project.license.key
      end

      should "not error out on repos with folders names license" do
        project = make_project "license-folder.git", as_git
        assert_equal nil, project.license
      end

      should "detect licence files" do
        project = make_project "licence.git", as_git
        assert_equal "mit", project.license.key
      end

      should "detect an unlicensed project" do
        project = make_project "no-license.git", as_git
        assert_equal nil, project.license
      end
    end
  end
end
