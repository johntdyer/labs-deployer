# encoding: utf-8

require "labs-deployer/version"
require 'thor'
require 'bundler'
require 'bundler/setup'
require 'berkshelf/thor'
require 'fileutils'
require 'digest/md5'
require 'mime/types'
require 'berkshelf/cli'
require 's3'
require 'labs-deployer/config'
class Solo < Thor

  Berkshelf::Config.new

  @config = VoxeoLabs::Config.new(
    File.dirname(
      Berkshelf.find_metadata(".")
    ).expand_path
  )

  p "===="
  p @config
  exit
  desc "package", "package and deploy a cookbook"

  def package
    get_dependencies
    pkg = package_files
    upload_cookbooks(pkg)
  end

  private

  def get_dependencies()
    say "Gathering cookbook dependencies", :green
    FileUtils.rm_rf("/tmp/cookbooks")
    invoke("berkshelf:install", [], path: "/tmp/cookbooks", berksfile: "./Berksfile")
  end

  def package_files
    say "== Packaging cookbook", :green
    `cd /tmp; tar zcf #{get_cookbook_name}.#{get_cookbook_version}.tgz ./cookbooks`
    return "/tmp/#{get_cookbook_name}.#{get_cookbook_version}.tgz"
  end

  def upload_cookbooks(file)
    service = S3::Service.new({
                                :access_key_id     =>  @config.aws_key, #Chef::Config[:knife][:aws_access_key_id],
                                :secret_access_key =>  @config.aws_secret #@Chef::Config[:knife][:aws_secret_access_key]
    })
    bucket = service.buckets.find(@config.bucket_name)
    say "== Uploading cookbook [#{file}]", :green

    ## Only upload files, we're not interested in directories
    if File.file?(file)
      remote_file = "#{get_cookbook_name}/#{file.split("/")[-1]}"

      begin
        obj = bucket.objects.find_first(remote_file)
        if yes? "This cookbook version already exists, do you want to overwrite it ?", :red
          say "== Ok, we'll overwrite it", :green
        else
          say "== Ok, exiting", :green
          exit 0
        end
      rescue
        obj = nil
      end

      say "== Uploading #{file}", :green
      obj = bucket.objects.build(remote_file)
      obj.content = open(file)
      obj.content_type = MIME::Types.type_for(file).to_s
      obj.save

    end
    say "== Done syncing #{file.split('/')[-1]}",:green
  end

  def get_cookbook_version
    IO.read(Berkshelf.find_metadata).match(/^version.*/).to_s.split('"')[1]
  end

  def get_cookbook_name

    return @config.project_name if @config.project_name

    name = IO.read(Berkshelf.find_metadata).match(/^name.*/).to_s.split('"')[1]
    if name.nil?
      return Dir.pwd.split("/")[-1]
    else
      return name
    end

  end

end
