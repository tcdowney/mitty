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

  let(:mitty_configuration) do
    double(
      Mitty::Configuration,
      thumbnail_image_size: thumbnail_image_size_config,
      small_image_size: small_image_size_config,
      medium_image_size: medium_image_size_config,
      large_image_size: large_image_size_config,
      generate_low_quality: generate_low_quality_config,
      strip_color_profiles: strip_color_profiles_config,
      normal_quality_value: normal_quality_value_config,
      aws_access_key_id: aws_access_key_id_config,
      aws_region: aws_region_config,
      aws_secret_access_key: aws_secret_access_key_config,
      aws_default_acl: aws_default_acl_config,
      aws_s3_bucket: aws_s3_bucket_config
    )
  end

  before do
    allow(Mitty).to receive(:configuration).and_return(mitty_configuration)
  end
end