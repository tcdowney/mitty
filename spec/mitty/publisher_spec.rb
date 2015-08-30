require 'spec_helper'

module Mitty
  RSpec.describe Publisher do
    include_context 'sample Mitty configuration'

    subject { Publisher.new }

    let(:aws_client) do
      double(Aws::S3::Client, put_object: nil)
    end
    
    before do
      allow(Aws::S3::Client).to receive(:new).and_return(aws_client)
    end

    describe '#initialize' do
      let(:expected_credentials) do
        {
          region: Mitty.configuration.aws_region,
          access_key_id: Mitty.configuration.aws_access_key_id,
          secret_access_key: Mitty.configuration.aws_secret_access_key
        }
      end

      it 'initializes an Aws::S3::Client with the appropriate credentials' do
        subject

        expect(Aws::S3::Client)
          .to have_received(:new)
          .with(expected_credentials)
      end
    end

    describe '#upload_image' do
      let(:file_path) { '/some/path/img.jpg' }
      let(:image) { double('Image') }

      before do
        allow(File).to receive(:read).with(file_path).and_return(image)

        subject.upload_image(path: file_path, **upload_options)
      end

      context 'when a custom acl is passed in' do
        let(:custom_acl) { 'custom-acl-level' }
        let(:upload_options) { {acl: custom_acl} }

        it 'uploads the image using the custom acl setting' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: custom_acl,
              body: image,
              bucket: Mitty.configuration.aws_s3_bucket,
              key: file_path
            )
        end
      end

      context 'when a custom S3 bucket is passed in' do
        let(:custom_bucket) { 'custom-bucket' }
        let(:upload_options) { {bucket: custom_bucket} }

        it 'uploads the image to the specified bucket' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: Mitty.configuration.aws_default_acl,
              body: image,
              bucket: custom_bucket,
              key: file_path
            )
        end
      end

      context 'when a custom key_prefix is passed in' do
        let(:custom_prefix) { 'prefix' }
        let(:expected_key) { "#{custom_prefix}/img.jpg" }
        let(:upload_options) { {key_prefix: custom_prefix} }

        it 'uploads the image using the custom key' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: Mitty.configuration.aws_default_acl,
              body: image,
              bucket: Mitty.configuration.aws_s3_bucket,
              key: expected_key
            )
        end
      end

      context 'when no optional arguments are provided' do
        let(:upload_options) { {} }

        it 'uploads the image using the configured settings by default' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: Mitty.configuration.aws_default_acl,
              body: image,
              bucket: Mitty.configuration.aws_s3_bucket,
              key: file_path
            )
        end
      end
    end

    describe '#upload_image_directory' do
      let(:image_directory_path) { '/some/path' }
      let(:image_file_path) { "#{image_directory_path}/img.jpg" }
      let(:image) { double('Image') }

      before do
        allow(Dir)
          .to receive(:glob)
          .with("#{image_directory_path}/*.jpg")
          .and_return([image_file_path])
          .and_yield(image_file_path)

        allow(File).to receive(:read).with(image_file_path).and_return(image)

        subject.upload_image_directory(path: image_directory_path, **upload_options)
      end

      context 'when a custom acl is passed in' do
        let(:custom_acl) { 'custom-acl-level' }
        let(:upload_options) { {acl: custom_acl} }

        it 'uploads the image using the custom acl setting' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: custom_acl,
              body: image,
              bucket: Mitty.configuration.aws_s3_bucket,
              key: image_file_path
            )
        end
      end

      context 'when a custom S3 bucket is passed in' do
        let(:custom_bucket) { 'custom-bucket' }
        let(:upload_options) { {bucket: custom_bucket} }

        it 'uploads the image to the specified bucket' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: Mitty.configuration.aws_default_acl,
              body: image,
              bucket: custom_bucket,
              key: image_file_path
            )
        end
      end

      context 'when a custom key_prefix is passed in' do
        let(:custom_prefix) { 'prefix' }
        let(:expected_key) { "#{custom_prefix}/img.jpg" }
        let(:upload_options) { {key_prefix: custom_prefix} }

        it 'uploads the image using the custom key' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: Mitty.configuration.aws_default_acl,
              body: image,
              bucket: Mitty.configuration.aws_s3_bucket,
              key: expected_key
            )
        end
      end

      context 'when no optional arguments are provided' do
        let(:upload_options) { {} }

        it 'uploads the image using the configured settings by default' do
          expect(aws_client)
            .to have_received(:put_object)
            .with(
              acl: Mitty.configuration.aws_default_acl,
              body: image,
              bucket: Mitty.configuration.aws_s3_bucket,
              key: image_file_path
            )
        end
      end
    end
  end
end