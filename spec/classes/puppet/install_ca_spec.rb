# frozen_string_literal: true

require 'spec_helper'

describe 'psick::puppet::install_ca' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }

      if os.include?('windows')
        it { is_expected.to compile }
      else
        it { is_expected.to compile }
      end
    end
  end
end
