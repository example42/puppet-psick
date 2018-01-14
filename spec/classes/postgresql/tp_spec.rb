require 'spec_helper'
require 'yaml'
facts_yaml = File.dirname(__FILE__) + '/../../fixtures/facts/spec.yaml'
facts = YAML.load_file(facts_yaml)

default_params = {
  'ensure'             => 'present',
  'options_hash'       => {},
  'settings_hash'      => {},
  'auto_prereq'        => true,
}

describe 'psick::postgresql::tp' do
  on_supported_os(facterversion: '2.4').select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-16.04-x86_64' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(facts) }
      let(:pre_condition) { 'include psick' }

      describe 'with default params' do
        it { is_expected.to compile }
        it { is_expected.to contain_tp__install('postgresql').with(default_params) }
      end

      describe 'with manage => false' do
        let(:params) { { 'manage' => false } }

        it { is_expected.to have_resource_count(0) }
      end

      describe 'with ensure => absent' do
        let(:params) { { 'ensure' => 'absent' } }

        it { is_expected.to contain_tp__install('postgresql').with(default_params.merge('ensure' => 'absent')) }
      end
    end
  end
end
