require 'spec_helper'

module Mitty
  RSpec.describe Configuration do
    let(:configuration) { Configuration.new }
    let(:config_from_file) { {} }

    shared_examples 'a configurable setting' do
      it 'can be configured' do
        subject = configured_value
        expect(subject).to eq(configured_value)
      end
    end

    describe 'configuration of settings' do
      before do
        allow_any_instance_of(Configuration)
          .to receive(:config_from_file)
          .and_return(config_from_file)
      end
      
      describe 'aws_access_key_id' do
        subject { configuration.aws_access_key_id }
        let(:configured_value) { 'some aws_access_key_id' }

        context 'when aws_access_key_id is configured in a config file' do
          let(:config_from_file) { {'aws_access_key_id' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when aws_access_key_id is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to an empty string' do
            expect(subject).to eq('')
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'aws_secret_access_key' do
        subject { configuration.aws_secret_access_key }
        let(:configured_value) { 'some aws_access_key_id' }

        context 'when aws_secret_access_key is configured in a config file' do
          let(:config_from_file) { {'aws_secret_access_key' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when aws_secret_access_key is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to an empty string' do
            expect(subject).to eq('')
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'aws_s3_bucket' do
        subject { configuration.aws_s3_bucket }
        let(:configured_value) { 'some aws_s3_bucket' }

        context 'when aws_s3_bucket is configured in a config file' do
          let(:config_from_file) { {'aws_s3_bucket' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when aws_s3_bucket is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to an empty string' do
            expect(subject).to eq('')
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'aws_region' do
        subject { configuration.aws_region }
        let(:configured_value) { 'some aws_region' }

        context 'when aws_region is configured in a config file' do
          let(:config_from_file) { {'aws_region' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when aws_region is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to "us-east-1"' do
            expect(subject).to eq('us-east-1')
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'aws_default_acl' do
        subject { configuration.aws_default_acl }
        let(:configured_value) { 'some aws_default_acl' }

        context 'when aws_default_acl is configured in a config file' do
          let(:config_from_file) { {'aws_default_acl' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when aws_default_acl is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to "private"' do
            expect(subject).to eq('private')
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'aws_original_copy_acl' do
        subject { configuration.aws_original_copy_acl }
        let(:configured_value) { 'some aws_original_copy_acl' }

        context 'when aws_original_copy_acl is configured in a config file' do
          let(:config_from_file) { {'aws_original_copy_acl' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when aws_original_copy_acl is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to "private"' do
            expect(subject).to eq('private')
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'thumbnail_image_size' do
        subject { configuration.thumbnail_image_size }
        let(:configured_value) { 'some thumbnail_image_size' }

        context 'when thumbnail_image_size is configured in a config file' do
          let(:config_from_file) { {'thumbnail_image_size' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when thumbnail_image_size is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to 125' do
            expect(subject).to eq(125)
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'small_image_size' do
        subject { configuration.small_image_size }
        let(:configured_value) { 'some small_image_size' }

        context 'when small_image_size is configured in a config file' do
          let(:config_from_file) { {'small_image_size' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when small_image_size is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to 250' do
            expect(subject).to eq(250)
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'medium_image_size' do
        subject { configuration.medium_image_size }
        let(:configured_value) { 'some medium_image_size' }

        context 'when medium_image_size is configured in a config file' do
          let(:config_from_file) { {'medium_image_size' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when medium_image_size is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to 500' do
            expect(subject).to eq(500)
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'large_image_size' do
        subject { configuration.large_image_size }
        let(:configured_value) { 'some large_image_size' }

        context 'when large_image_size is configured in a config file' do
          let(:config_from_file) { {'large_image_size' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when large_image_size is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to 1000' do
            expect(subject).to eq(1000)
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'normal_quality_value' do
        subject { configuration.normal_quality_value }
        let(:configured_value) { 'some normal_quality_value' }

        context 'when normal_quality_value is configured in a config file' do
          let(:config_from_file) { {'normal_quality_value' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when normal_quality_value is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to 95' do
            expect(subject).to eq(95)
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'low_quality_value' do
        subject { configuration.low_quality_value }
        let(:configured_value) { 'some low_quality_value' }

        context 'when low_quality_value is configured in a config file' do
          let(:config_from_file) { {'low_quality_value' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when low_quality_value is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to 50' do
            expect(subject).to eq(50)
          end

          it_behaves_like 'a configurable setting'
        end
      end

      describe 'generate_low_quality' do
        subject { configuration.generate_low_quality }
        let(:configured_value) { 'some generate_low_quality' }

        context 'when generate_low_quality is configured in a config file' do
          let(:config_from_file) { {'generate_low_quality' => configured_value} }

          it 'is set to its value from the configuration file' do
            expect(subject).to eq(configured_value)
          end

          it_behaves_like 'a configurable setting'
        end

        context 'when generate_low_quality is not configured in a config file' do
          let(:config_from_file) { {} }

          it 'defaults to false' do
            expect(subject).to be false
          end

          it_behaves_like 'a configurable setting'
        end
      end
    end

    describe '#config_from_file' do
      subject { configuration.config_from_file }

      let(:current_directory_mitty_file) { './.mitty' }
      let(:home_directory_mitty_file) { "#{Dir.home}/.mitty" }
      let(:current_directory_config) { {'some_configuration' => 'some_configuration'} }
      let(:home_directory_config) { {'some_other_configuration' => 'some_other_configuration'} }

      context 'when a .mitty file exists in the current directory' do
        before do
          allow(File)
            .to receive(:exists?)
            .with(current_directory_mitty_file)
            .and_return(true)

          allow(YAML)
            .to receive(:load_file)
            .with(current_directory_mitty_file)
            .and_return(current_directory_config)
        end

        it 'returns the parsed configuration from the current directory\'s .mitty file' do
          expect(subject).to eq(current_directory_config)
        end
      end

      context 'when a .mitty file exists in the home directory' do
        before do
          allow(File)
            .to receive(:exists?)
            .with(current_directory_mitty_file)
            .and_return(false)

          allow(File)
            .to receive(:exists?)
            .with(home_directory_mitty_file)
            .and_return(true)

          allow(YAML)
            .to receive(:load_file)
            .with(home_directory_mitty_file)
            .and_return(home_directory_config)
        end

        it 'returns the parsed configuration from the home directory\'s .mitty file' do
          expect(subject).to eq(home_directory_config)
        end
      end

      context 'when no .mitty file can be inferred' do
        before do
          allow(File)
            .to receive(:exists?)
            .with(current_directory_mitty_file)
            .and_return(false)

          allow(File)
            .to receive(:exists?)
            .with(home_directory_mitty_file)
            .and_return(false)
        end

        it 'returns an empty Hash' do
          expect(subject).to eq({})
        end
      end
    end
  end
end
