# frozen_string_literal: true

require 'spec_helper'

describe 'psick::bolt::master' do
  on_supported_os.each do |os, os_facts|
    skip "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick ; include psick::bolt' }
      before(:each) {
        Puppet::Parser::Functions.newfunction(:puppetdb_query, :type => :rvalue) {
            |args| other_function.call(args[0], args[1])
        }
    
        # This is a default if you don't want to specify the values for every test
        puppetdb_query.stubs(:call).returns(preset_values)
      }

      if os.include?('windows')
        it { is_expected.to compile.and_raise_error(/.*/) }
      else
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
