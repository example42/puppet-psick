require 'spec_helper'

describe 'psick::limits::limit' do
  let(:title) { 'test/nproc' }
  let(:params) do
    {
      'soft' => 2048
    }
  end
  let(:pre_condition) { 'include psick' }

  on_supported_os.select { |_, f| f[:os]['name'] == 'RedHat' and f[:os]['release']['major'] == '7' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os.include?('windows')
        it { is_expected.to compile.and_raise_error(/.*/) }
      else
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
