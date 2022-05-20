# frozen_string_literal: true

require 'spec_helper'

describe 'psick::yum::plugin' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os.include?('windows')
        it { is_expected.to compile }
      else
        it { is_expected.to compile }
      end
    end
  end
end
