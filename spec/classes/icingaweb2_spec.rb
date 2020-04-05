require 'spec_helper'

describe 'psick::icingaweb2' do
  on_supported_os(facterversion: '2.4').select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-16.04-x86_64' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick ; tp::install { epel: } ; include psick::icinga2' }

      it { is_expected.to compile }
    end
  end
end
