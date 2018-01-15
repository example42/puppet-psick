require 'spec_helper'
require 'yaml'
facts_yaml = File.dirname(__FILE__) + '/../fixtures/facts/spec.yaml'
facts = YAML.load_file(facts_yaml)

describe 'psick::firstrun', type: :class do
  let(:pre_condition) { "Exec { path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin' } ; include '::psick'" }
  let(:facts) { facts.merge(firstrun: 'done')  }

  on_supported_os.select { |_, f| f[:os]['name'] == 'RedHat' && f[:os]['release']['major'] == '7' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f.merge(super())
      end
      let(:params) do
        { manage: true }
      end

      it { is_expected.to compile.with_all_deps }

      describe 'by default' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_reboot_resource_count(0) }
        it { is_expected.to contain_psick__puppet__set_external_fact('firstrun').without('notify') }
      end

      describe 'with linux_reboot = true' do
        let(:params) do
          {
            manage: true,
            linux_reboot: true,
          }
        end

        it { is_expected.to contain_reboot('Rebooting') }
        it { is_expected.to contain_psick__puppet__set_external_fact('firstrun').with('notify' => 'Reboot[Rebooting]', 'value' => 'done') }
      end

      describe 'with custom _class params' do
        let(:params) do
          {
            manage: true,
            linux_classes: {
              hostname: 'psick::hostname',
              repo: 'psick::repo',
              packages: 'psick::aws::sdk',
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('psick::hostname') }
        it { is_expected.to contain_class('psick::repo') }
        it { is_expected.to contain_class('psick::aws::sdk') }
      end

      describe 'with custom reboot params' do
        let(:params) do
          {
            manage: true,
            linux_reboot: true,
            reboot_apply: 'immediately',
            reboot_message: 'test',
            reboot_when: 'refreshed',
            reboot_timeout: 30,
            reboot_name: 'test reboot',
          }
        end

        it { is_expected.to contain_psick__puppet__set_external_fact('firstrun').with('notify' => 'Reboot[test reboot]', 'value' => 'done') }
        it { is_expected.to contain_reboot('test reboot').only_with('apply' => 'immediately', 'message' => 'test', 'when' => 'refreshed', 'timeout' => 30) }
      end

      describe 'with manage => false' do
        let(:params) do
          { manage: false }
        end

        it { is_expected.to have_class_count(5) }
        it { is_expected.to have_resource_count(0) }
      end
    end
  end
  on_supported_os.select { |_, f| f[:os]['name'] == 'Windows' && f[:os]['release']['major'] == '2016' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f.merge(super())
      end
      let(:params) do {
        'manage' => true,
      } end

      it { is_expected.to compile.with_all_deps }

      describe 'with hieradata defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_reboot('Rebooting') }
        it { is_expected.to contain_psick__puppet__set_external_fact('firstrun').with('notify' => 'Reboot[Rebooting]', 'value' => 'done') }
      end

      describe 'with custom _class params' do
        let(:params) do {
          'manage' => true,
          'windows_classes' => {
            'hostname' => 'psick::hostname',
            'packages' => 'psick::aws::sdk'
          }
        } end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('psick::hostname') }
        it { is_expected.to contain_class('psick::aws::sdk') }
      end

      describe 'with windows_reboot => false' do
        let(:params) do {
          manage: true,
          windows_reboot: false,
        } end

        it { is_expected.not_to contain_reboot('Rebooting') }
        it { is_expected.to contain_psick__puppet__set_external_fact('firstrun').without(['notify']) }
      end
    end
  end
end
