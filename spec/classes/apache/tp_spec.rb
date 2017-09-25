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
sample_settings_hash = {
  'package_name'     => 'my_apache',
  'service_name'     => 'my_apache',
  'config_dir_path'  => '/etc/my_apache',
  'config_file_path' => '/etc/my_apache/config.yaml',
}
sample_resources_hash = {
  'tp::conf' => {
    'apache' => {
      'template' => 'psick/spec/sample.erb',
    },
    'apache::other' => {
      'source' => 'puppet:///psick/spec/sample',
    },
  },
  'tp::dir' => {
    'apache' => {
      'source'  => 'git@github.com:/example42.com/psick',
      'vcsrepo' => 'git',
      'path'    => '/opt/psick',
    },
    'apache::other' => {
      'source' => 'puppet:///psick/spec',
    },
  },
}
sample_options_hash = {
  'server' => {
    'host' => 'localhost',
    'port' => '1',
  },
  'url' => 'http://sample/',
}

describe 'psick::apache::tp' do
  on_supported_os(facterversion: '2.4').select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-16.04-x86_64' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(facts) }
      let(:pre_condition) { 'include psick' }

      describe 'with default params' do
        it { is_expected.to compile }
        it { is_expected.to contain_tp__install('apache').with(default_params) }
      end

      describe 'with manage => false' do
        let(:params) { { 'manage' => false } }

        it { is_expected.to have_resource_count(0) }
      end

      describe 'with ensure => absent' do
        let(:params) { { 'ensure' => 'absent' } }

        it { is_expected.to contain_tp__install('apache').with(default_params.merge('ensure' => 'absent')) }
      end

      describe 'with custom conf_hash' do
        let(:params) { { 'resources_hash' => sample_resources_hash, 'options_hash' => sample_options_hash } }

        it { is_expected.to contain_tp__install('apache').with(default_params.merge('options_hash' => sample_options_hash)) }
        it { is_expected.to contain_tp__conf('apache').with('ensure' => 'present', 'template' => 'psick/spec/sample.erb', 'options_hash' => sample_options_hash) }
        it { is_expected.to contain_tp__conf('apache::other').with('ensure' => 'present', 'source' => 'puppet:///psick/spec/sample') }
        it { is_expected.to contain_tp__dir('apache').with('ensure' => 'present', 'path' => '/opt/psick', 'vcsrepo' => 'git', 'source' => 'git@github.com:/example42.com/psick') }
        it { is_expected.to contain_tp__dir('apache::other').with('ensure' => 'present', 'source' => 'puppet:///psick/spec') }
      end

      describe 'with custom settings_hash' do
        let(:params) do
          {
            'settings_hash' => sample_settings_hash,
            'resources_hash' => sample_resources_hash,
            'options_hash' => sample_options_hash,
          }
        end

        it { is_expected.to contain_tp__install('apache').with(default_params.merge('options_hash' => sample_options_hash, 'settings_hash' => sample_settings_hash)) }
        it { is_expected.to contain_tp__conf('apache').with('ensure' => 'present', 'template' => 'psick/spec/sample.erb') }
        it { is_expected.to contain_tp__conf('apache::other').with('ensure' => 'present', 'source' => 'puppet:///psick/spec/sample') }
        it { is_expected.to contain_tp__dir('apache').with('ensure' => 'present', 'source' => 'git@github.com:/example42.com/psick') }
        it { is_expected.to contain_package('my_apache').with('ensure' => 'present') }
        it { is_expected.to contain_service('my_apache').with('ensure' => 'running', 'enable' => true) }
        it { is_expected.to contain_file('/etc/my_apache/config.yaml').with('ensure' => 'present') }
        it { is_expected.to contain_file('/etc/my_apache').with('ensure' => 'directory') }
      end

      describe 'with auto_prereq => false' do
        let(:params) { { 'auto_prereq' => false } }

        it { is_expected.to contain_tp__install('apache').with(default_params.merge('auto_repo' => false, 'auto_prereq' => false)) }
      end
    end
  end
end
