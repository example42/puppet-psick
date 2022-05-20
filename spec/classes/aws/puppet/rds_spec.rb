# frozen_string_literal: true

require 'spec_helper'

describe 'psick::aws::puppet::rds' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick ; include psick::aws' }
      let(:params) do {
        'default_master_user_password' => 'oh',
      } end

      if os.include?('windows')
        it { is_expected.to compile.and_raise_error(/.*/) }
      else
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
