# frozen_string_literal: true

require 'spec_helper'

describe 'psick::hosts::puppetdb' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }
      before(:each) {
        Puppet::Parser::Functions.newfunction(:puppetdb_query, :type => :rvalue) {
            |args| other_function.call(args[0], args[1])
        }
    
        # This is a default if you don't want to specify the values for every test
        other_function.stubs(:call).returns(preset_values)
      }

      it { is_expected.to compile }
    end
  end
end
