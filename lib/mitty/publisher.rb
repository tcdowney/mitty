require 'aws-sdk'

module Mitty
  class Publisher
    attr_reader :aws_client

    AWS_ACL_VALUES = %w[
      private public-read public-read-write authenticated-read bucket-owner-read bucket-owner-full-control
    ]

    def initialize
      @aws_client = Aws::S3::Client.new(
        region: Mitty.configuration.aws_region,
        access_key_id: Mitty.configuration.aws_access_key_id,
        secret_access_key: Mitty.configuration.aws_secret_access_key
      )
    end

    # Public: Uploads a single image to an Amazon Web Services S3 bucket.  The AWS S3 object's key
    # defaults to the provided path.  An optional :key_prefix can be provided to replace the path in the object's
    # key.
    #
    # options - A Hash of options used for uploading the image
    #           :path        - The path to the image you wish to upload
    #           :acl:        - A valid AWS ACL value (as defined in AWS_ACL_VALUES) (default: the configured value)
    #           :bucket:     - An Amazon S3 bucket name (default: the configured value)
    #           :key_prefix: - A prefix used to prepend to the object's key on AWS S3 (optional)
    #
    # Returns nothing.
    def upload_image(
      path: ,
      acl: Mitty.configuration.aws_default_acl, 
      bucket: Mitty.configuration.aws_s3_bucket,
      key_prefix: nil
    )
      image = File.read(path)
      key = key_prefix ? "#{key_prefix}/#{File.basename(path)}" : path

      aws_client.put_object(
        acl: acl,
        body: image,
        bucket: bucket,
        key: key
      )
    end

    # Public: Uploads a directory of images to an Amazon Web Services S3 bucket.  The AWS S3 objects' keys
    # default to their paths on the file system.  An optional :key_prefix can be provided to replace the 
    # path in each object's key.
    #
    # options - A Hash of options used for uploading the images
    #           :path        - The path to the images you wish to upload
    #           :acl:        - A valid AWS ACL value (as defined in AWS_ACL_VALUES) (default: the configured value)
    #           :bucket:     - An Amazon S3 bucket name (default: the configured value)
    #           :key_prefix: - A prefix used to prepend to each object's key on AWS S3 (optional)
    #
    # Returns nothing.
    def upload_image_directory(
      path: , 
      acl: Mitty.configuration.aws_default_acl, 
      bucket: Mitty.configuration.aws_s3_bucket,
      key_prefix: nil
    )
      Dir.glob("#{path}/*.jpg") do |image_path|
        image = File.read(image_path)
        key = key_prefix ? "#{key_prefix}/#{File.basename(image_path)}" : image_path

        aws_client.put_object(
          acl: acl,
          body: image,
          bucket: bucket,
          key: key
        )
      end
    end
  end
end