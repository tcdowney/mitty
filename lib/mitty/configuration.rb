require 'yaml'

module Mitty
  class Configuration
    # AWS Config
    attr_accessor :aws_access_key_id, :aws_secret_access_key, :aws_s3_bucket, :aws_region,
                  :aws_default_acl, :aws_original_copy_acl

    # Image Config
    attr_accessor :thumbnail_image_size, :small_image_size, :medium_image_size, 
                  :large_image_size, :normal_quality_value, :low_quality_value,
                  :generate_low_quality, :strip_color_profiles

    def initialize
      @aws_access_key_id = config_from_file['aws_access_key_id'] || ''
      @aws_secret_access_key = config_from_file['aws_secret_access_key'] || ''
      @aws_s3_bucket = config_from_file['aws_s3_bucket'] || ''
      @aws_region = config_from_file['aws_region'] || 'us-east-1'
      @aws_default_acl = config_from_file['aws_default_acl'] || 'private'
      @aws_original_copy_acl = config_from_file['aws_original_copy_acl'] || 'private'

      @thumbnail_image_size = config_from_file['thumbnail_image_size'] || 125
      @small_image_size = config_from_file['small_image_size'] || 250
      @medium_image_size = config_from_file['medium_image_size'] || 500
      @large_image_size = config_from_file['large_image_size'] || 1000
      @normal_quality_value = config_from_file['normal_quality_value'] || 95
      @low_quality_value = config_from_file['low_quality_value'] || 50

      @generate_low_quality = config_from_file['generate_low_quality'] || false
      @strip_color_profiles = config_from_file['strip_color_profiles'] || false
    end

    private

    # Internal: Reads config from the default configuration file locations.
    # First checks for a .mitty file in the current directory, then looks for one in
    # the user's home directory.  Defaults to {} if no configuration file available.
    #
    # Returns a Hash containing String keys
    def config_from_file
      config = if File.exists? './.mitty'
        YAML.load_file('./.mitty')
      elsif File.exists? "#{Dir.home}/.mitty"
        YAML.load_file("#{Dir.home}/.mitty")
      else
        {}
      end

      config
    end
  end
end