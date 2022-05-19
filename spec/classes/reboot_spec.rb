# frozen_string_literal: true

require 'spec_helper'

describe 'psick::reboot' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }

      if os.include?('windows')
        it { is_expected.to compile }
      else
        it { is_expected.to compile.and_raise_error(/.*/) }
      end
    end
  end
end
