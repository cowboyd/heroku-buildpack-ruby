require 'language_pack/rails3'

module LanguagePack
  class Rails3Artifact < Rails3
    attr_reader :artifact_revision

    class << self
      def artifact_name
        ENV["ARTIFACT_NAME"]
      end

      def use?
        super && artifact_name
      end
    end

    def name
      "Ruby/Rails Artifact"
    end

    def remove_vendor_bundle
      puts "[SKIP] remove_vendor_bundle"
    end
    def run_assets_precompile_rake_task
      puts "[SKIP] assets_precompile"
    end

    def build_bundler
      puts "[SKIP] bundle"
    end

    def compile
      puts "deploy artifact"
      wipeout!
      download!
      unpack!
      super
    end

    private

    def wipeout!
      puts "destroy source"
      ENV.each do |key, value|
        puts "#{key} #{value}"
      end
      puts run("ls -R /app")
      puts run("GIT_DIR=/app/tmp/repo.git git rev-parse master")
      @artifact_revision = run("GIT_DIR=/app/tmp/repo.git git rev-parse HEAD").chomp
      run "rm -rf #{build_path}/*"
    end

    def download!
      artifact_url = "#{artifact_catalog_url}/#{artifact_name}/#{artifact_name}-#{artifact_revision}.tgz"
      puts "downloading artifact #{artifact_url}"
      Dir.chdir build_path do
        run("curl #{artifact_url} -s -o - | tar zxf -")
      end
    end

    def artifact_catalog_url
      ENV['ARTIFACT_CATALOG_URL']
    end

    def artifact_name
      self.class.artifact_name
    end

  end
end
