require 'spec_helper'
require 'yaml'
facts_yaml = File.dirname(__FILE__) + '/../fixtures/facts/spec.yaml'
facts = YAML.load_file(facts_yaml)
pre_cond_exec = "Exec { path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin' }"
describe 'psick', type: :class do
  let(:pre_condition) { "#{pre_cond_exec}" }
  let(:facts) { facts }

  on_supported_os.select { |_, f| f[:os]['name'] == 'RedHat' and f[:os]['release']['major'] == '7' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f.merge(super())
      end

      it { is_expected.to compile.with_all_deps }

      describe 'with default settings' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_class_count(4) }
        it { is_expected.to have_resource_count(0) }

        it { is_expected.to contain_class('psick::pre').that_comes_before(['Class[psick::base]', 'Class[psick::profiles]']) }
        it { is_expected.to contain_class('psick::base').that_comes_before('Class[psick::profiles]') }
        it { is_expected.to contain_class('psick::profiles') }
      end

      describe 'with auto_conf => hardened' do
        let(:params) do
          { auto_conf: 'hardened' }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('psick::sysctl') }
        it { is_expected.to contain_class('psick::update') }
        it { is_expected.to contain_class('psick::openssh::tp') }
        it { is_expected.to contain_class('psick::hardening') }
      end

      describe 'with manage => false' do
        let(:params) do
          { manage: false }
        end

        it { is_expected.to have_class_count(4) }
        it { is_expected.to have_resource_count(0) }
      end

      describe 'with enable_firstrun = true' do
        let(:params) do
          { enable_firstrun: true }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_reboot_resource_count(0) }
        it { is_expected.to contain_psick__puppet__set_external_fact('firstrun').without('notify') }
      end

      describe 'with force_ordering = true' do
        let(:params) do
          { force_ordering: true }
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_class_count(4) }
        it { is_expected.to have_resource_count(0) }

        #it { is_expected.to contain_class('psick::pre').that_not_comes_before(['Class[psick::base]', 'Class[psick::profiles]']) }
        #it { is_expected.to contain_class('psick::base').that_not_comes_before('Class[psick::profiles]') }
      end

    end
  end
end
