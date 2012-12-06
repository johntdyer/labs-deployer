module VoxeoLabs
  class Config
    require 'pathname'
    require 'yaml'

    CONFIG_NAME=".deployer"

    attr_reader :bucket_name, :aws_secret, :aws_key, :project_name


    def initialize

      Pathname.new(File.dirname(__FILE__)).ascend do |dir|
        config_file = dir + CONFIG_NAME
        if dir.children.include?(config_file)
          merge_config(YAML::load_file(config_file))
        end
      end

    end

    private

    def merge_config(config)

      if config['bucket_name']
        @bucket_name = config['bucket_name'] unless @bucket_name
      end

      if config['aws_secret']
        @aws_secret = config['aws_secret'] unless @aws_secret
      end

      if config['aws_key']
        @aws_key = config['aws_key'] unless @aws_key
      end

      if config['project_name']
        @project_name = c['project_name'] unless @project_name
      end

    end

  end
end
