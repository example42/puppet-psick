# frozen_string_literal: true

require 'spec_helper'

describe 'psick::time::windows' do
  on_supported_os.each do |os, os_facts|
    skip "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick; include psick::time' }

      if os.include?('windows')
        it { is_expected.to compile }
      else
        it { is_expected.to compile }
      end
    end
  end
end
