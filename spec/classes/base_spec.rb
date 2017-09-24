require 'spec_helper'
require 'yaml'
facts_yaml = File.dirname(__FILE__) + '/../fixtures/facts/spec.yaml'
facts = YAML.load_file(facts_yaml)
pre_cond_exec = "Exec { path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin' }"
pre_cond_psick = "class psick ( $manage = true ) { include psick::pre ; include psick::profiles } ; include psick"
describe 'psick::base', type: :class do
  let(:pre_condition) { "#{pre_cond_exec} ; #{pre_cond_psick}" }
  let(:facts) { facts }

  on_supported_os.select { |_, f| f[:os]['name'] == 'RedHat' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f.merge(super())
      end

      it { is_expected.to compile.with_all_deps }

      describe 'with default settings' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_class_count(4) }
        it { is_expected.to have_resource_count(0) }
      end

      describe 'with auto_conf => hardened' do
        let(:params) do
          { auto_conf: 'hardened' }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('psick::dns::resolver') }
        it { is_expected.to contain_class('psick::hostname') }
        it { is_expected.to contain_class('psick::users::static') }
        it { is_expected.to contain_class('psick::sudo') }
        it { is_expected.to contain_class('psick::logs::rsyslog') }
        it { is_expected.to contain_class('psick::time') }
        it { is_expected.to contain_class('psick::sysctl') }
        it { is_expected.to contain_class('psick::update') }
        it { is_expected.to contain_class('psick::motd') }
        it { is_expected.to contain_class('psick::openssh::tp') }
        it { is_expected.to contain_class('psick::hardening') }
      end

      describe 'with manage => false' do
        let(:params) do
          { manage: false }
        end

        it { is_expected.to have_class_count(2) }
        it { is_expected.to have_resource_count(0) }
      end
    end
  end
end
