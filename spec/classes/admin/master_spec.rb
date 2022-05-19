# frozen_string_literal: true

require 'spec_helper'

describe 'psick::admin::master' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick ; include psick::admin' }

      it { is_expected.to compile }
    end
  end
end
