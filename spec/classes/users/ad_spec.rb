# frozen_string_literal: true

require 'spec_helper'

describe 'psick::users::ad' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include psick' }
      let(:params) do {
        'domain' => 'oh',
        'username' => 'oh',
        'password' => 'oh',
        'machine_ou' => 'oh',
      } end

      it { is_expected.to compile }
    end
  end
end