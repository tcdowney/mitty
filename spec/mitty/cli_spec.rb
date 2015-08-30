require 'spec_helper'

module Mitty
  RSpec.describe CLI do
    include_context 'sample Mitty configuration'

    let(:path) { 'some/input/path' }
    let(:output_path) { 'some/output/path' }
    let(:darkroom_resize_output_directory) { 'some/resize/dir' }
    let(:darkroom_originals_output_directory) { 'some/originals/dir' }
    let(:darkroom_output_dir_name) { 'some-dir-name' }
    let(:darkroom_originals_dir_name) { 'some-originals-dir-name' }
    let(:options) { {} }
    let(:darkroom) { 
      double(
        Darkroom, 
        resize_images: darkroom_resize_output_directory, 
        create_thumbnails: darkroom_resize_output_directory, 
        create_all_sizes: darkroom_resize_output_directory,
        copy_originals: darkroom_originals_output_directory,
        output_directory_name: darkroom_output_dir_name,
        copied_originals_directory_name: darkroom_originals_dir_name
      ) 
    }
    let(:publisher) {
      double(
        Publisher,
        upload_image: nil,
        upload_image_directory: nil
      )
    }

    before do
      subject.options = options
    end

    describe '#resize' do
      before do
        allow(subject).to receive(:apply_custom_config)

        allow(subject)
          .to receive(:output_path)
          .with(path)
          .and_return(output_path)

        allow(Darkroom)
          .to receive(:new)
          .and_return(darkroom)
      end

      context 'with any options' do
        before do
          subject.resize path
        end

        it 'applies custom configuration values' do
          expect(subject).to have_received(:apply_custom_config)
        end

        it 'initializes a new darkroom instance with the proper paths' do
          expect(Darkroom).to have_received(:new).with(path, output_path)
        end
      end

      context 'when a path is not passed in' do
        let(:current_directory_path) { '.' }

        before do
          allow(subject)
            .to receive(:output_path)
            .with(current_directory_path)
            .and_return(output_path)

          subject.resize
        end

        it 'defaults the path to the current directory' do
          expect(Darkroom)
            .to have_received(:new).with(current_directory_path, output_path)
        end
      end

      context 'when the --size "all" argument is provided' do
        let(:options) { {size: 'all'} }

        before do
          subject.resize path
        end

        it 'creates all sizes' do
          expect(darkroom).to have_received(:create_all_sizes)
        end

        it 'creates thumbnails' do
          expect(darkroom).to have_received(:create_thumbnails)
        end
      end

      context 'when the --size "thumbs" argument is provided' do
        let(:options) { {size: 'thumbs'} }

        before do
          subject.resize path
        end

        it 'does not create all sizes' do
          expect(darkroom).not_to have_received(:create_all_sizes)
        end

        it 'creates thumbnails' do
          expect(darkroom).to have_received(:create_thumbnails)
        end
      end

      context 'when a valid size is provided' do
        let(:size) { 'small' }
        let(:options) { {size: size} }

        before do
          subject.resize path
        end

        it 'does not create all sizes' do
          expect(darkroom).not_to have_received(:create_all_sizes)
        end

        it 'does not create thumbnails' do
          expect(darkroom).not_to have_received(:create_thumbnails)
        end

        it 'it resizes the images to the appropriate size' do
          expect(darkroom).to have_received(:resize_images).with(size)
        end
      end
    end

    describe '#upload' do
      before do
        allow(subject).to receive(:apply_custom_config)
        allow(subject).to receive(:apply_aws_credential_overrides)

        allow(Publisher)
          .to receive(:new)
          .and_return(publisher)
      end

      context 'when the provided path is a directory' do
        before do
          allow(File)
            .to receive(:directory?)
            .with(path)
            .and_return(true)

          subject.upload path
        end

        it 'applies custom configuration values' do
          expect(subject).to have_received(:apply_custom_config)
        end

        it 'applies custom aws credential values' do
          expect(subject).to have_received(:apply_aws_credential_overrides)
        end

        context 'when the privacy option is provided' do
          let(:custom_privacy_level) { 'public-read-write' }
          let(:options) { {privacy: custom_privacy_level} }
          let(:expected_upload_options) { 
            {path: path, acl: custom_privacy_level} 
          }

          it 'uploads the directory with the custom privacy level' do
            expect(publisher)
              .to have_received(:upload_image_directory)
              .with(expected_upload_options)
          end
        end

        context 'when the aws_bucket option is provided' do
          let(:custom_aws_bucket) { 'SERN-data-warehouse' }
          let(:options) { {aws_bucket: custom_aws_bucket} }
          let(:expected_upload_options) { 
            {path: path, bucket: custom_aws_bucket} 
          }

          it 'uploads the directory to the specified aws bucket' do
            expect(publisher)
              .to have_received(:upload_image_directory)
              .with(expected_upload_options)
          end
        end

        context 'when the object_key_prefix option is provided' do
          let(:custom_object_key_prefix) { 'AD 2010.7.28' }
          let(:options) { {object_key_prefix: custom_object_key_prefix} }
          let(:expected_upload_options) { 
            {path: path, key_prefix: custom_object_key_prefix} 
          }

          it 'uploads the images with the provided object key prefix' do
            expect(publisher)
              .to have_received(:upload_image_directory)
              .with(expected_upload_options)
          end
        end

        context 'when no special upload_options are provided' do
          let(:expected_upload_options) { {path: path} }

          it 'uploads the directory in the given path' do
            expect(publisher)
              .to have_received(:upload_image_directory)
              .with(expected_upload_options)
          end
        end
      end

      context 'when the provided path is a single file' do
        before do
          allow(File)
            .to receive(:directory?)
            .with(path)
            .and_return(false)

          subject.upload path
        end

        it 'applies custom configuration values' do
          expect(subject).to have_received(:apply_custom_config)
        end

        it 'applies custom aws credential values' do
          expect(subject).to have_received(:apply_aws_credential_overrides)
        end

        context 'when the privacy option is provided' do
          let(:custom_privacy_level) { 'public-read-write' }
          let(:options) { {privacy: custom_privacy_level} }
          let(:expected_upload_options) { 
            {path: path, acl: custom_privacy_level} 
          }

          it 'uploads the directory with the custom privacy level' do
            expect(publisher)
              .to have_received(:upload_image)
              .with(expected_upload_options)
          end
        end

        context 'when the aws_bucket option is provided' do
          let(:custom_aws_bucket) { 'future-gadget-lab-store' }
          let(:options) { {aws_bucket: custom_aws_bucket} }
          let(:expected_upload_options) { 
            {path: path, bucket: custom_aws_bucket} 
          }

          it 'uploads the directory to the specified aws bucket' do
            expect(publisher)
              .to have_received(:upload_image)
              .with(expected_upload_options)
          end
        end

        context 'when the object_key_prefix option is provided' do
          let(:custom_object_key_prefix) { 'AD 2010.7.28' }
          let(:options) { {object_key_prefix: custom_object_key_prefix} }
          let(:expected_upload_options) { 
            {path: path, key_prefix: custom_object_key_prefix} 
          }

          it 'uploads the images with the provided object key prefix' do
            expect(publisher)
              .to have_received(:upload_image)
              .with(expected_upload_options)
          end
        end

        context 'when no special upload_options are provided' do
          let(:expected_upload_options) { {path: path} }

          it 'uploads the directory in the given path' do
            expect(publisher)
              .to have_received(:upload_image)
              .with(expected_upload_options)
          end
        end
      end
    end

    describe '#manage' do
      let(:standard_key_prefix) { darkroom_output_dir_name }
      let(:originals_key_prefix) { 
        "#{darkroom_output_dir_name}/#{darkroom_originals_dir_name}"
      }

      before do
        allow(subject).to receive(:apply_custom_config)
        allow(subject).to receive(:apply_aws_credential_overrides)
        allow(subject)
          .to receive(:output_path)
          .with(path)
          .and_return(output_path)

        allow(Publisher)
          .to receive(:new)
          .and_return(publisher)

        allow(Darkroom)
          .to receive(:new)
          .and_return(darkroom)

        subject.manage path
      end

      it 'applies custom configuration values' do
        expect(subject).to have_received(:apply_custom_config)
      end

      it 'applies custom aws credential values' do
        expect(subject).to have_received(:apply_aws_credential_overrides)
      end

      it 'initializes a darkroom instance with the correct paths' do
        expect(Darkroom)
          .to have_received(:new)
          .with(path, output_path)
      end

      it 'creates thumbnails' do
        expect(darkroom).to have_received(:create_thumbnails)
      end

      it 'creates all possible sizes of images' do
        expect(darkroom).to have_received(:create_all_sizes)
      end

      it 'copies the original images' do
        expect(darkroom).to have_received(:copy_originals)
      end

      context 'when the aws_bucket option is specified' do
        let(:bucket) { 'ibn-5100-images' }
        let(:options) { {aws_bucket: bucket} }
        let(:expected_standard_upload_options) {
          {
            path: darkroom_resize_output_directory,
            bucket: bucket,
            key_prefix: standard_key_prefix
          }
        }
        let(:expected_originals_upload_options) {
          {
            path: darkroom_originals_output_directory,
            acl: aws_original_copy_acl_config,
            bucket: bucket,
            key_prefix: originals_key_prefix
          }
        }

        it 'uploads the resized images with the correct options' do
          expect(publisher)
            .to have_received(:upload_image_directory)
            .with(expected_standard_upload_options)
        end

        it 'uploads the original images with the correct options' do
          expect(publisher)
            .to have_received(:upload_image_directory)
            .with(expected_originals_upload_options)
        end
      end

      context 'when the aws_bucket option is not specified' do
        let(:options) { {} }
        let(:expected_standard_upload_options) {
          {
            path: darkroom_resize_output_directory,
            key_prefix: standard_key_prefix
          }
        }
        let(:expected_originals_upload_options) {
          {
            path: darkroom_originals_output_directory,
            acl: aws_original_copy_acl_config,
            key_prefix: originals_key_prefix
          }
        }

        it 'uploads the resized images with the correct options' do
          expect(publisher)
            .to have_received(:upload_image_directory)
            .with(expected_standard_upload_options)
        end

        it 'uploads the original images with the correct options' do
          expect(publisher)
            .to have_received(:upload_image_directory)
            .with(expected_originals_upload_options)
        end
      end

    end

    describe '#verbose_log' do
      let(:log_message) { 'some verbose log message' }

      before do
        allow(subject).to receive(:puts)

        subject.verbose_log log_message
      end

      context 'when the verbose option is true' do
        let(:options) { {verbose: true} }

        it 'puts the log message' do
          expect(subject).to have_received(:puts).with(log_message)
        end
      end

      context 'when the verbose option is false' do
        let(:options) { {verbose: false} }

        it 'does not call puts with the log message' do
          expect(subject).not_to have_received(:puts).with(log_message)
        end
      end
    end

    describe '#apply_custom_config' do
      let(:custom_config_path) { 'ibn/custom/config.yml' }
      let(:custom_thumbnail_image_size) { 9_000_000 }
      let(:standard_configuration) {
        {
          thumbnail_image_size: 400
        }
      }
      let(:custom_configuration) {
        {
          thumbnail_image_size: custom_thumbnail_image_size,
          invalid_config: 5_100
        }
      }

      before do
        allow(YAML)
          .to receive(:load_file)
          .and_return(standard_configuration)

        allow(YAML)
          .to receive(:load_file)
          .with(custom_config_path)
          .and_return(custom_configuration)

        allow(Mitty).to receive(:configure).and_call_original
      end

      context 'when a custom configuration file is provided' do
        let(:options) { {config: custom_config_path} }

        it 'configures Mitty' do
          subject.apply_custom_config

          expect(Mitty).to have_received(:configure)
        end

        it 'ignores invalid configuration' do
          expect { 
            subject.apply_custom_config 
          }.not_to raise_error(NoMethodError)
        end

        it 'applies valid configuration correctly' do
          subject.apply_custom_config

          expect(Mitty.configuration.thumbnail_image_size)
            .to eq(custom_thumbnail_image_size)
        end
      end

      context 'when a custom configuration file is not provided' do
        let(:options) { {} }

        it 'does not reconfigure Mitty' do
          subject.apply_custom_config

          expect(Mitty).not_to have_received(:configure)
        end
      end
    end

    describe '#apply_aws_credential_overrides' do
      let(:env_access_key_id) { 'access key id env variable' }
      let(:option_access_key_id) { 'access key id from cli options' }
      let(:config_file_access_key_id) { 'access key id from config file' }

      let(:env_secret_access_key) { 'secret access key env variable' }
      let(:option_secret_access_key) { 'secret access key from cli options' }
      let(:config_file_secret_access_key) { 'config file secret access key' }

      let(:config_file_configuration) {
        {
          'aws_access_key_id' => config_file_access_key_id,
          'aws_secret_access_key' => config_file_secret_access_key
        }
      }

      before do
        allow(YAML)
          .to receive(:load_file)
          .and_return(config_file_configuration)
      end

      context 'when environment variables are present' do
        before do
          allow(ENV).to receive(:[]).and_call_original

          allow(ENV)
            .to receive(:[])
            .with('AWS_ACCESS_KEY_ID')
            .and_return(env_access_key_id)

          allow(ENV)
            .to receive(:[])
            .with('AWS_SECRET_ACCESS_KEY')
            .and_return(env_secret_access_key)

          subject.apply_aws_credential_overrides
        end

        context 'when aws cli option overrides are present' do
          let(:options) { 
            {
              access_key_id: option_access_key_id,
              secret_access_key: option_secret_access_key
            } 
          }

          it 'configures aws_access_key_id according to the option' do
            expect(Mitty.configuration.aws_access_key_id)
              .to eq(option_access_key_id)
          end

          it 'configures aws_secret_access_key according to the option' do
            expect(Mitty.configuration.aws_secret_access_key)
              .to eq(option_secret_access_key)
          end
        end

        context 'when aws cli option overrides are not present' do
          let(:options) { {} }

          it 'configures aws_access_key_id to the ENV variable value' do
            expect(Mitty.configuration.aws_access_key_id)
              .to eq(env_access_key_id)
          end

          it 'configures aws_secret_access_key to the ENV variable value' do
            expect(Mitty.configuration.aws_secret_access_key)
              .to eq(env_secret_access_key)
          end
        end
      end

      context 'when environment variables are not present' do
        before do
          allow(ENV).to receive(:[]).and_call_original

          allow(ENV)
            .to receive(:[])
            .with('AWS_ACCESS_KEY_ID')
            .and_return(nil)

          allow(ENV)
            .to receive(:[])
            .with('AWS_SECRET_ACCESS_KEY')
            .and_return(nil)

          subject.apply_aws_credential_overrides
        end

        context 'when aws cli option overrides are present' do
          let(:options) { 
            {
              access_key_id: option_access_key_id,
              secret_access_key: option_secret_access_key
            } 
          }

          it 'configures aws_access_key_id according to the option' do
            expect(Mitty.configuration.aws_access_key_id)
              .to eq(option_access_key_id)
          end

          it 'configures aws_secret_access_key according to the option' do
            expect(Mitty.configuration.aws_secret_access_key)
              .to eq(option_secret_access_key)
          end
        end

        context 'when aws cli option overrides are not present' do
          let(:options) { {} }

          it 'does not modify the aws_access_key_id configuration' do
            expect(Mitty.configuration.aws_access_key_id)
              .to eq(aws_access_key_id_config)
          end

          it 'does not modify the aws_secret_access_key configuration' do
            expect(Mitty.configuration.aws_secret_access_key)
              .to eq(aws_secret_access_key_config)
          end
        end
      end
    end

    describe '#output_path' do
      context 'when the output option is specified' do
        let(:options) { {output: output_path} }

        it 'returns the provided output path' do
          expect(subject.output_path(path)).to eq(output_path)
        end
      end

      context 'when the output option is not specified' do
        let(:options) { {} }

        it 'returns the input path' do
          expect(subject.output_path(path)).to eq(path)
        end
      end
    end
  end
end