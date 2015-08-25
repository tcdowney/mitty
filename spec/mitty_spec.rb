require 'spec_helper'

RSpec.describe Mitty do
  it 'has a version number' do
    expect(Mitty::VERSION).not_to be nil
  end

  describe '.configuration' do
    it 'returns a Mitty::Configuration object' do
      expect(described_class.configuration).to be_kind_of(Mitty::Configuration)
    end
  end

  describe '.configure' do
    let(:expected_configuration_value) { 'some config value' }

    it 'allows the configuration to be modified' do
      described_class.configure { |config| config.aws_region = expected_configuration_value }

      expect(described_class.configuration.aws_region).to eq(expected_configuration_value)
    end
  end
end
