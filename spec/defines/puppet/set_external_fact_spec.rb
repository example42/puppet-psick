# frozen_string_literal: true

require 'spec_helper'

describe 'psick::puppet::set_external_fact' do
  let(:title) { 'namevar' }
  let(:params) do {
    'value' => 'oh',
  } end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      #TODO Add windows support
      if os.include?('windows')
        it { is_expected.to compile.and_raise_error(/.*/) }
      else
        it { is_expected.to compile }
      end
    end
  end
end
