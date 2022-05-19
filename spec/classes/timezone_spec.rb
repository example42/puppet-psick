# frozen_string_literal: true

require 'spec_helper'

describe 'psick::timezone' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'class { psick: timezone => "utc" } '  }

      it { is_expected.to compile }
    end
  end
end
