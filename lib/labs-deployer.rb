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

class Solo < Thor

  Berkshelf.load_config

  AWS_ACCESS_KEY_ID      =  Chef::Config[:knife][:aws_access_key_id]
  AWS_SECRET_ACCESS_KEY  =  Chef::Config[:knife][:aws_secret_access_key]
  AWS_BUCKET             =  Chef::Config[:knife][:bucket]

  desc "package", "package and deploy a cookbook"

  def package

    #get_dependencies
    pkg = package_files
    #upload_cookbooks(pkg)
  end

  private

  def get_dependencies()
    say "Gathering cookbook dependencies", :green
    `mkdir -p /tmp/berkshelf-tmp`
    invoke("berkshelf:install", [], path: "/tmp/berkshelf-tmp", berksfile: "./Berksfile")
  end

  def package_files
    say "Packaging cookbook", :green
    `tar zcf #{get_cookbook_name}.#{get_cookbook_version}.tgz -C /tmp/berkshelf-tmp .`
    FileUtils.mv "#{get_cookbook_name}.#{get_cookbook_version}.tgz", '/tmp'
    return "/tmp/#{get_cookbook_name}.#{get_cookbook_version}.tgz"
  end

  def upload_cookbooks(file)
    service = S3::Service.new({
                           :access_key_id     =>  AWS_ACCESS_KEY_ID,
                           :secret_access_key =>  AWS_SECRET_ACCESS_KEY
                           })

    bucket = service.buckets.find(AWS_BUCKET)

    say "Uploading cookbook [#{file}]", :green

    ## Only upload files, we're not interested in directories
    if File.file?(file)
      remote_file = "#{get_cookbook_name}/#{file.split("/")[-1]}"

      begin
        obj = bucket.objects.find_first(remote_file)
        if yes? "This cookbook version already exists, do you want to overwrite it ?", :red
          say "Ok, we'll overwrite it", :green
        else
          say "Ok, exiting", :green
          exit 0
        end
      rescue
        obj = nil
      end

      ## If the object does not exist, or if the MD5 Hash / etag of the file has changed, upload it.
      if !obj || (obj.etag != Digest::MD5.hexdigest(File.read(file)))
        say "Uploading #{file}", :green
        obj = bucket.objects.build(remote_file)
        obj.content = open(file)
        obj.content_type = MIME::Types.type_for(file).to_s
        obj.save
      else
        say "Skipping duplicate file [ #{file} ]", :yellow
      end
    end
    say "== Done syncing #{file.split('/')[-1]}",:green
  end

  def get_cookbook_version
    #Berkshelf.find_metadata
    IO.read(Berkshelf.find_metadata).match(/^version.*/).to_s.split('"')[1]
  end

  def get_cookbook_name
    Dir.pwd.split("/")[-1]
  end

end
