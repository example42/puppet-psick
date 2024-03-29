# frozen_string_literal: true

require 'spec_helper'

describe 'psick::puppet::foss_master' do
  on_supported_os.each do |os, os_facts|
    skip "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }

      if os.include?('windows')
        it { is_expected.to compile.and_raise_error(/.*/) }
      elsif os.include?('SLES')
        it { is_expected.to compile }
      else
        it { is_expected.to compile }
      end
    end
  end
end
