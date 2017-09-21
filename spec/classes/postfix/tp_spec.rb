require 'spec_helper'

describe 'psick::postfix::tp' do
  on_supported_os(facterversion: '2.4').select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-16.04-x86_64' }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      default_params = {
        'ensure'             => 'present',
        'options_hash'       => {},
        'settings_hash'      => {},
        'auto_repo'          => true,
        'auto_prerequisites' => true,
      }

      describe 'with default params' do
        it { is_expected.to compile }
        it { is_expected.to contain_tp__install('psick::postfix').with(default_params) }
      end

      describe 'with ensure => absent' do
        let(:params) { { 'ensure' => 'absent' } }

        it { is_expected.to contain_tp__install('psick::postfix').with(default_params.merge('ensure' => 'absent')) }
      end

      describe 'with auto_prereq => false' do
        let(:params) { { 'auto_prereq' => false } }

        it { is_expected.to contain_tp__install('psick::postfix').with(default_params.merge('auto_repo' => false, 'auto_prerequisites' => false)) }
      end

      describe 'with custom conf_hash' do
        sample_conf_hash = {
          'main' => {
            'template' => 'profile/spec/sample.erb',
          },
          'other' => {
            'source' => 'puppet:///profile/spec/sample',
          },
        }
        sample_options_hash = {
          'server' => {
            'host' => 'localhost',
            'port' => '1',
          },
          'url' => 'http://sample/',
        }
        let(:params) { { 'conf_hash' => sample_conf_hash, 'options_hash' => sample_options_hash } }

        it { is_expected.to contain_tp__install('psick::postfix').with(default_params.merge('options_hash' => sample_options_hash)) }
        it { is_expected.to contain_tp__conf('psick::postfix::main').with('ensure' => 'present', 'template' => 'profile/spec/sample.erb', 'options_hash' => sample_options_hash) }
        it { is_expected.to contain_tp__conf('psick::postfix::other').with('ensure' => 'present', 'source' => 'puppet:///profile/spec/sample') }
      end

      describe 'with custom dir_hash' do
        sample_dir_hash = {
          'psick' => {
            'source'  => 'git@github.com:/example42.com/psick',
            'vcsrepo' => 'git',
            'path'    => '/opt/psick',
          },
          'sample' => {
            'source' => 'puppet:///profile/spec',
          },
        }
        let(:params) { { 'dir_hash' => sample_dir_hash } }

        it { is_expected.to contain_tp__install('psick::postfix').with(default_params.merge('options_hash' => sample_options_hash)) }
        it { is_expected.to contain_tp__dir('psick::postfix::psick').with('ensure' => 'present', 'path' => '/opt/psick', 'vcsrepo' => 'git', 'source' => 'git@github.com:/example42.com/psick') }
        it { is_expected.to contain_tp__dir('psick::postfix::sample').with('ensure' => 'present', 'source' => 'puppet:///profile/spec') }
      end

      describe 'with custom settings_hash' do
        sample_settings_hash = {
          'package_name'     => 'my_psick::postfix',
          'service_name'     => 'my_psick::postfix',
          'config_dir_path'  => '/etc/my_psick::postfix',
          'config_file_path' => '/etc/my_psick::postfix/config.yaml',
        },
        sample_dir_hash = {
          '' => {
            'source' => 'puppet:///profile/spec/sample',
          },
        }
        sample_conf_hash = {
          '' => {
            'source' => 'puppet:///profile/spec',
          },
        }
        let(:params) do {
          'settings_hash' => sample_settings_hash,
          'dir_hash'      => sample_dir_hash,
          'conf_hash'     => sample_conf_hash, 
        } end

        it { is_expected.to contain_tp__install('psick::postfix').with(default_params.merge('options_hash' => sample_options_hash)) }
        it { is_expected.to contain_tp__conf('psick::postfix').with('ensure' => 'present', 'source' => 'puppet:///profile/spec/sample') }
        it { is_expected.to contain_tp__dir('psick::postfix').with('ensure' => 'present', 'source' => 'puppet:///profile/spec') }
        it { is_expected.to contain_package('my_psick::postfix').with('ensure' => 'present',)
        it { is_expected.to contain_service('my_psick::postfix').with('ensure' => 'present',)
        it { is_expected.to contain_file('/etc/my_psick::postfix/config.yaml').with('ensure' => 'present',)
        it { is_expected.to contain_file('/etc/my_psick::postfix').with('ensure' => 'directory',)
    end
  end
end
