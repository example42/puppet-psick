require 'spec_helper'

describe 'psick::kmod' do
  on_supported_os.select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-18.04-x86_64' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }

      describe 'with default params' do
        it { is_expected.to compile }
      end
    end
  end
end
