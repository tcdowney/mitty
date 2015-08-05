require 'spec_helper'

module Mitty
  RSpec.describe Darkroom do
    include_context 'sample Mitty configuration'

    let(:input_path) { 'my input path' }
    let(:output_path) { 'my output path' }

    subject { Darkroom.new(input_path, output_path) }

    describe '#output_directory_name' do
      let(:current_date_time) { DateTime.new(2015, 1, 5) }
      let(:expected_date_string) { current_date_time.to_date.to_s }

      before do
        allow(DateTime).to receive(:now).and_return(current_date_time)
      end

      it 'returns the current date as a String' do
        expect(subject.output_directory_name).to eq(expected_date_string)
      end
    end

    describe '#copied_originals_directory_name' do
      it 'returns the String "originals"' do
        expect(subject.copied_originals_directory_name).to eq('originals')
      end
    end

    describe '#create_thumbnails' do
      let(:output_directory) { '/my/output/directory' }
      let(:image) { double(Magick::Image) }
      let(:image_file_name) { 'file1.jpg' }
      let(:expected_image_output_path) { "#{output_directory}/file1_thumb.jpg"}
      let(:test_image_files) { [image_file_name] }

      before do
        allow(subject).to receive(:create_output_directory).and_return(output_directory)
        allow(Dir)
          .to receive(:glob)
          .with("#{subject.input_path}/*.jpg")
          .and_return(test_image_files)
          .and_yield(image_file_name)

        allow(Magick::Image)
          .to receive(:read)
          .with(image_file_name)
          .and_return([image])

        allow(image).to receive_messages(
          resize_to_fill!: nil,
          write: nil,
          destroy!: nil
        )

        subject.create_thumbnails
      end

      it 'resizes the images in the directory' do
        expect(image).to have_received(:resize_to_fill!).with(mitty_configuration.thumbnail_image_size)
      end

      it 'writes the images to the appropriate path' do
        expect(image).to have_received(:write).with(expected_image_output_path)
      end

      it 'calls destroy! on the images to free up memory' do
        expect(image).to have_received(:destroy!)
      end

      it 'returns the path to which the images were written' do
        expect(subject.create_thumbnails).to eq(output_directory)
      end
    end

    describe '#create_all_sizes' do
      let(:resized_images_output_path) { 'some/output/path' }

      before do
        allow(subject)
          .to receive(:resize_images)
          .and_return(resized_images_output_path)

        subject.create_all_sizes
      end

      it 'creates small images' do
        expect(subject)
          .to have_received(:resize_images)
          .once
          .with(Darkroom::SMALL)
      end

      it 'creates medium images' do
        expect(subject)
          .to have_received(:resize_images)
          .once
          .with(Darkroom::MEDIUM)
      end

      it 'creates large images' do
        expect(subject)
          .to have_received(:resize_images)
          .once
          .with(Darkroom::LARGE)
      end

      it 'returns the path to which the images were written' do
        expect(subject.create_all_sizes).to eq(resized_images_output_path)
      end
    end

    describe '#copy_originals' do
      let(:output_directory) { '/my/output/directory' }
      let(:originals_directory_name) { 'originals' }
      let(:expected_originals_output_path) { "#{output_directory}/#{originals_directory_name}"}
      let(:image_file_name) { 'file1.jpg' }
      let(:test_image_files) { [image_file_name] }

      before do
        allow(subject).to receive_messages(
          create_output_directory: output_directory,
          copied_originals_directory_name: originals_directory_name
        )

        allow(File)
          .to receive(:exists?)
          .with(expected_originals_output_path)
          .and_return(true)

        allow(Dir)
          .to receive(:glob)
          .with("#{subject.input_path}/*.jpg")
          .and_return(test_image_files)
          .and_yield(image_file_name)

        allow(FileUtils).to receive(:cp)
      end

      context 'when the output directory does not already exist' do
        before do
          allow(File)
            .to receive(:exists?)
            .with(expected_originals_output_path)
            .and_return(false)

          allow(Dir).to receive(:mkdir)
          subject.copy_originals
        end

        it 'creates the output directory' do
          expect(Dir)
            .to have_received(:mkdir)
            .with(expected_originals_output_path)
        end
      end

      context 'when the output directory already exists' do
        before do
          allow(File)
            .to receive(:exists?)
            .with(expected_originals_output_path)
            .and_return(true)

          allow(Dir).to receive(:mkdir)
          subject.copy_originals
        end

        it 'creates the output directory' do
          expect(Dir)
            .not_to have_received(:mkdir)
            .with(expected_originals_output_path)
        end
      end

      it 'copies the images to the new directory' do
        subject.copy_originals

        expect(FileUtils)
          .to have_received(:cp)
          .with(image_file_name, expected_originals_output_path)
      end

      it 'returns the directory to which the files were copied' do
        expect(subject.copy_originals).to eq(expected_originals_output_path)
      end
    end

    describe '#resize_images' do
      let(:output_directory) { '/my/output/directory' }
      let(:image_file_name) { 'file1.jpg' }
      let(:image) { double(Magick::Image) }
      let(:expected_image_output_path) { "#{output_directory}/file1_small.jpg"}
      let(:expected_low_quality_path) { "#{output_directory}/file1_small_lq.jpg"}
      let(:test_image_files) { [image_file_name] }

      before do
        allow(subject).to receive(:create_output_directory).and_return(output_directory)
        allow(Dir)
          .to receive(:glob)
          .with("#{subject.input_path}/*.jpg")
          .and_return(test_image_files)
          .and_yield(image_file_name)

        allow(Magick::Image)
          .to receive(:read)
          .with(image_file_name)
          .and_return([image])

        allow(image).to receive_messages(
          resize_to_fit!: nil,
          write: nil,
          destroy!: nil
        )
      end

      context 'when the generate_low_quality configuration option is enabled' do
        let(:generate_low_quality_config) { true }

        before do
          subject.resize_images(Darkroom::SMALL)
        end

        it 'resizes the images in the directory' do
          expect(image).to have_received(:resize_to_fit!).with(mitty_configuration.small_image_size)
        end

        it 'writes the images to the appropriate path' do
          expect(image).to have_received(:write).with(expected_image_output_path)
        end

        it 'writes out low quality versions' do
          expect(image).to have_received(:write).with(expected_low_quality_path)
        end

        it 'calls destroy! on the images to free up memory' do
          expect(image).to have_received(:destroy!)
        end

        it 'returns the path to which the images were written' do
          expect(subject.resize_images(Darkroom::SMALL)).to eq(output_directory)
        end
      end

      context 'when the generate_low_quality configuration option is not enabled' do
        let(:generate_low_quality_config) { false }

        before do
          subject.resize_images(Darkroom::SMALL)
        end

        it 'resizes the images in the directory' do
          expect(image).to have_received(:resize_to_fit!).with(mitty_configuration.small_image_size)
        end

        it 'writes the images to the appropriate path' do
          expect(image).to have_received(:write).with(expected_image_output_path)
        end

        it 'writes out low quality versions' do
          expect(image).not_to have_received(:write).with(expected_low_quality_path)
        end

        it 'calls destroy! on the images to free up memory' do
          expect(image).to have_received(:destroy!)
        end

        it 'returns the path to which the images were written' do
          expect(subject.resize_images(Darkroom::SMALL)).to eq(output_directory)
        end
      end
    end

    describe '#create_output_directory' do
      let(:output_directory_name) { 'my-directory' }
      let(:expected_output_directory_path) { "#{output_path}/#{output_directory_name}"}

      before do
        allow(subject).to receive(:output_directory_name).and_return(output_directory_name)
      end

      context 'when the output directory does not already exist' do
        before do
          allow(File)
            .to receive(:exists?)
            .with(expected_output_directory_path)
            .and_return(false)

          allow(Dir).to receive(:mkdir)
        end

        it 'creates the output directory' do
          subject.send(:create_output_directory)
          expect(Dir)
            .to have_received(:mkdir)
            .with(expected_output_directory_path)
        end

        it 'returns the output directory path' do
          expect(subject.send(:create_output_directory)).to eq(expected_output_directory_path)
        end
      end

      context 'when the output directory already exists' do
        before do
          allow(File)
            .to receive(:exists?)
            .with(expected_output_directory_path)
            .and_return(true)

          allow(Dir).to receive(:mkdir)
        end

        it 'creates the output directory' do
          subject.send(:create_output_directory)
          expect(Dir)
            .not_to have_received(:mkdir)
            .with(expected_output_directory_path)
        end

        it 'returns the output directory path' do
          expect(subject.send(:create_output_directory)).to eq(expected_output_directory_path)
        end
      end
    end

    describe '#image_output_path' do
      let(:image_file_basename) { 'file1' }
      let(:image_file_ext) { '.jpg' }
      let(:input_file_path) { "some-path/#{image_file_basename}#{image_file_ext}" }
      let(:suffix) { '_suffix' }
      let(:output_path_root) { 'some/output/path' }
      let(:expected_image_output_path) { 
        "#{output_path_root}/#{image_file_basename}#{suffix}#{image_file_ext}" 
      }

      it 'returns the generated image output path' do
        expect(subject.send(:image_output_path, input_file_path, output_path_root, suffix))
          .to eq(expected_image_output_path)
      end
    end
  end
end