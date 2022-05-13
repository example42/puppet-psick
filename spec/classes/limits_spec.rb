require 'spec_helper'

describe 'psick::limits' do
  on_supported_os.select { |_, f| f[:os]['name'] == 'RedHat' and f[:os]['release']['major'] == '7' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }

      it { is_expected.to compile }
    end
  end
end
