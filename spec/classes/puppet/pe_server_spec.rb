# frozen_string_literal: true

require 'spec_helper'

describe 'psick::puppet::pe_server' do
  on_supported_os.each do |os, os_facts|
    # Skipping because module which provides Pe_puppet_authorization::Rule
    # is not public
    skip "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }

      if os.include?('windows')
        it { is_expected.to compile.and_raise_error(/.*/) }
      else
        it { is_expected.to compile }
      end
    end
  end
end
