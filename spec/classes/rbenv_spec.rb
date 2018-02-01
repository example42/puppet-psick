require 'spec_helper'

describe 'psick::rbenv' do
  on_supported_os(facterversion: '2.4').select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-16.04-x86_64' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }
      it { is_expected.to compile }
      it { is_expected.to contain_class('rbenv') }
      it { is_expected.to contain_rbenv__plugin('rbenv/ruby-build') }
      it { is_expected.to contain_rbenv__build('2.4.2') }

      describe 'with manage => false' do
        let(:params) { { 'manage' => false } }

        it { is_expected.to have_resource_count(0) }
      end
    end
  end
end
