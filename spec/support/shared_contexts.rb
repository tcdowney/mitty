RSpec.shared_context 'sample Mitty configuration' do
  let(:thumbnail_image_size_config) { 100 }
  let(:small_image_size_config) { 200 }
  let(:medium_image_size_config) { 300 }
  let(:large_image_size_config) { 400 }
  let(:generate_low_quality_config) { false }
  let(:strip_color_profiles_config) { false }
  let(:normal_quality_value_config) { 89 }
  let(:aws_access_key_id_config) { 'Access Key ID' }
  let(:aws_region_config) { 'some-aws-region' }
  let(:aws_secret_access_key_config) { 'Secret Access Key' }
  let(:aws_default_acl_config) { 'some acl config' }
  let(:aws_s3_bucket_config) { 'some bucket' }
  let(:aws_original_copy_acl_config) { 'some-privacy-level' }

  let(:mitty_configuration) do
    Mitty::Configuration.new.tap { |config|
      config.thumbnail_image_size = thumbnail_image_size_config
      config.small_image_size = small_image_size_config
      config.medium_image_size = medium_image_size_config
      config.large_image_size = large_image_size_config
      config.generate_low_quality = generate_low_quality_config
      config.strip_color_profiles = strip_color_profiles_config
      config.normal_quality_value = normal_quality_value_config
      config.aws_access_key_id = aws_access_key_id_config
      config.aws_region = aws_region_config
      config.aws_secret_access_key = aws_secret_access_key_config
      config.aws_default_acl = aws_default_acl_config
      config.aws_s3_bucket = aws_s3_bucket_config
      config.aws_original_copy_acl = aws_original_copy_acl_config 
    }
  end

  before do
    allow(Mitty).to receive(:configuration).and_return(mitty_configuration)
  end
end