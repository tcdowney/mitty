require 'mitty/darkroom'
require 'yaml'
require 'thor'

module Mitty
  class CLI < Thor
    class_option :verbose, type: :boolean, aliases: '-v'

    desc 'resize PATH', 'Resizes a directory of images to a given size'
    option :output, desc: 'Path of the output directory', aliases: '-o'
    option :config, desc: 'Path to an optional config file', aliases: '-c'
    option :size, default: 'all', 
                  enum: ['all', 'thumbs'].concat(Darkroom::IMAGE_SIZES),
                  desc: 'Desired target size',
                  aliases: '-s'
    def resize(path = '.')
      apply_custom_config

      darkroom = Darkroom.new(path, output_path(path))

      verbose_log("Resizing jpg images in #{path} to the following size: #{options[:size]}")
      case options[:size]
      when 'all'
        darkroom.create_thumbnails
        darkroom.create_all_sizes
      when 'thumbs'
        darkroom.create_thumbnails
      else
        darkroom.resize_images(options[:size])
      end
    end

    desc 'upload PATH', 'Uploads a directory of images to an Amazon Web Services S3 bucket'
    option :access_key_id, desc: 'AWS access key ID', aliases: '-a'
    option :secret_access_key, desc: 'AWS secret access key', aliases: '-s'
    option :aws_bucket, desc: 'AWS bucket identifier', aliases: '-b'
    option :object_key_prefix, desc: 'AWS bucket identifier', aliases: '-k'
    option :privacy, desc: 'AWS ACL privacy level', enum: Publisher::AWS_ACL_VALUES, aliases: '-p'
    option :config, desc: 'Path to an optional config file', aliases: '-c'
    def upload(path = '.')
      apply_custom_config
      apply_aws_credential_overrides

      publisher = Publisher.new
      upload_options = {
        path: path, 
        acl: options[:privacy], 
        bucket: options[:aws_bucket], 
        key_prefix: options[:object_key_prefix]
      }.compact

      verbose_log("Uploading to AWS S3 with the following options: #{upload_options}")
      if File.directory?(path)
        publisher.upload_image_directory(upload_options)
      else
        publisher.upload_image(upload_options)
      end
    end

    desc 'manage PATH', 'Creates a variety of sizes, copies originals, and uploads to an AWS S3 Bucket'
    option :output, desc: 'Path of the output directory', aliases: '-o'
    option :access_key_id, desc: 'AWS access key ID', aliases: '-a'
    option :secret_access_key, desc: 'AWS secret access key', aliases: '-s'
    option :aws_bucket, desc: 'AWS bucket identifier', aliases: '-b'
    option :config, desc: 'Path to an optional config file', aliases: '-c'
    def manage(path = '.')
      apply_custom_config
      apply_aws_credential_overrides

      verbose_log("Processing jpg images in #{path}")
      darkroom = Darkroom.new(path, output_path(path))
      darkroom.create_thumbnails
      resized_images_output_path = darkroom.create_all_sizes
      originals_output_path = darkroom.copy_originals

      publisher = Publisher.new
      standard_upload_options = {
        path: resized_images_output_path,
        bucket: options[:aws_bucket],
        key_prefix: "#{darkroom.output_directory_name}"
      }.compact

      verbose_log("Uploading processed images to S3 with the following options: #{standard_upload_options}")
      publisher.upload_image_directory(standard_upload_options)

      original_copy_upload_options = {
        path: originals_output_path,
        acl: Mitty.configuration.aws_original_copy_acl,
        bucket: options[:aws_bucket],
        key_prefix: "#{darkroom.output_directory_name}/#{darkroom.copied_originals_directory_name}"
      }.compact

      verbose_log("Uploading original images to S3 with the following options: #{standard_upload_options}")
      publisher.upload_image_directory(original_copy_upload_options)
    end

    no_commands do
      def verbose_log(str)
        return unless options[:verbose]

        puts str
      end

      def apply_custom_config
        return unless options[:config]
        verbose_log("Applying custom configuration from: #{options[:config]}")

        config_file = YAML.load_file(options[:config])
        Mitty.configure do |config|
          config_file.each do |k, v| 
            config.send("#{k}=", v) if config.respond_to? "#{k}="
          end
        end
      end

      def apply_aws_credential_overrides
        Mitty.configuration.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID'] if ENV['AWS_ACCESS_KEY_ID']
        Mitty.configuration.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY'] if ENV['AWS_SECRET_ACCESS_KEY']

        Mitty.configuration.aws_access_key_id = options[:access_key_id] if options[:access_key_id]
        Mitty.configuration.aws_secret_access_key = options[:secret_access_key] if options[:secret_access_key]
      end

      def output_path(input_path)
        options[:output].presence || input_path
      end
    end

  end
end
