# frozen_string_literal: true

require 'spec_helper'

describe 'psick::php::pear::config' do
  let(:title) { 'namevar' }
  let(:params) do
    { 'value': 'oh' }
  end
  let(:pre_condition) { 'include psick::php::pear' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
