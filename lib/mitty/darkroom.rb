require 'rmagick'
require 'date'

module Mitty
  class Darkroom
    include Magick

    SMALL = 'small'
    MEDIUM = 'medium'
    LARGE = 'large'
    IMAGE_SIZES = [SMALL, MEDIUM, LARGE]

    attr_accessor :input_path, :output_path

    def initialize(input_path, output_path)
      @input_path = input_path
      @output_path = output_path
    end

    # Public: Creates "thumbnail" versions of all jpg images in the @input_path directory.
    # Outputs the thumbnails to a folder named for today's current date within
    # the @output_path directory.
    #
    # Returns a String denoting the path to which the thumbnails were outputted
    def create_thumbnails
      thumbnail_output_path = create_output_directory

      Dir.glob("#{input_path}/*.jpg") do |jpg_file|
        image_output_path = image_output_path(jpg_file, thumbnail_output_path, '_thumb')

        image = Magick::Image.read(jpg_file).first
        image.resize_to_fill!(Mitty.configuration.thumbnail_image_size)

        image.write(image_output_path) { self.quality = Mitty.configuration.normal_quality_value }

        if Mitty.configuration.generate_low_quality
          lq_image_output_path = image_output_path(jpg_file, thumbnail_output_path, '_thumb_lq')
          image.write(lq_image_output_path) { self.quality = Mitty.configuration.low_quality_value }
        end

        image.destroy!
      end

      thumbnail_output_path
    end

    # Public: Creates different sized versions of all jpg images in the @input_path directory.
    # Outputs the different sized images to a folder named for today's current date within
    # the @output_path directory.  The different sizes are defined in the IMAGE_SIZES constant.
    #
    # Returns a String denoting the path to which the images were outputted
    def create_all_sizes
      resized_images_output_path = ''

      IMAGE_SIZES.each do |size|
        resized_images_output_path = resize_images(size)
      end

      resized_images_output_path
    end

    # Public: Creates copies of all jpg images in the @input_path directory.
    # Copies the images to a folder named 'originals' located within a folder named 
    # for today's date which exists within the @output_path directory.
    #
    # Returns a String denoting the path to which the images were copied
    def copy_originals
      copied_originals_output_path = "#{create_output_directory}/#{copied_originals_directory_name}"
      Dir.mkdir copied_originals_output_path unless File.exists?(copied_originals_output_path)

      Dir.glob("#{input_path}/*.jpg") do |jpg_file|
        FileUtils.cp(jpg_file, copied_originals_output_path)
      end

      copied_originals_output_path
    end

    # Public: Resizes all of the jpg images in the @input_path directory to a given size.
    # Outputs the resized images to a folder named for today's current date within
    # the @output_path directory.
    #
    # size - String containing a valid size as defined within the IMAGE_SIZES constant
    #
    # Returns a String denoting the path to which the images were outputted
    def resize_images(size)
      resized_images_output_path = create_output_directory

      Dir.glob("#{input_path}/*.jpg") do |jpg_file|
        image_output_path = image_output_path(jpg_file, resized_images_output_path, "_#{size}")

        image = Magick::Image.read(jpg_file).first
        image.resize_to_fit!(Mitty.configuration.send("#{size}_image_size"))
        image.write(image_output_path) { self.quality = Mitty.configuration.normal_quality_value }

        if Mitty.configuration.generate_low_quality
          lq_image_output_path = image_output_path(jpg_file, resized_images_output_path, "_#{size}_lq")
          image.write(lq_image_output_path) { self.quality = Mitty.configuration.low_quality_value }
        end

        image.destroy!
      end

      resized_images_output_path
    end

    # Public: The name of the directory that will be created within the @output_path directory.
    # Currently this is today's date.
    #
    # Returns a String denoting the name of the directory
    def output_directory_name
      DateTime.now.to_date.to_s
    end

    # Public: The name of the directory that will be created within the @output_path directory.
    # Currently this is 'originals'.
    #
    # Returns a String denoting the name of the directory
    def copied_originals_directory_name
      'originals'
    end

    private

    # Internal: Creates the directory to which processed images will be outputted to if
    # it does not already exist.
    #
    # Returns a String denoting the directory's path
    def create_output_directory
      output_directory_path = "#{output_path}/#{output_directory_name}"

      Dir.mkdir output_directory_path unless File.exists?(output_directory_path)
      output_directory_path
    end

    # Internal: Constructs the ultimate path to which image will be saved to.
    # Given an optional suffix, appends it to the image's filename.
    #
    # input_file_path  - the path of the original image file
    # output_path_root - the path to which the image will be outputted
    # file_suffix      - an optional suffix to be appended to the image's filename (default: nil)
    #
    # Returns a String denoting the directory's path
    def image_output_path(input_file_path, output_path_root, file_suffix = nil)
      image_file_ext = File.extname(input_file_path)
      image_file_base = File.basename(input_file_path, image_file_ext)

      "#{output_path_root}/#{image_file_base}#{file_suffix}#{image_file_ext}"
    end
  end
end