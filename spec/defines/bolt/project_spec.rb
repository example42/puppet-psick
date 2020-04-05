require 'spec_helper'

describe 'psick::bolt::project' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-18.04-x86_64' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
