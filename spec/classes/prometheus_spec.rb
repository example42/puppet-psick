require 'spec_helper'
require 'yaml'
facts_yaml = File.dirname(__FILE__) + '/../fixtures/facts/spec.yaml'
facts = YAML.load_file(facts_yaml)
pre_cond_exec = "Exec { path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin' } ; include psick"
describe 'psick::prometheus', type: :class do
  let(:pre_condition) { "#{pre_cond_exec}" }
  let(:facts) { facts }

  on_supported_os.select { |_, f| f[:os]['name'] == 'RedHat' && f[:os]['release']['major'] == '7' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f.merge(super())
      end

      it { is_expected.to compile.with_all_deps }

      describe 'with default settings' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
