# frozen_string_literal: true

require 'spec_helper'

describe 'psick::nfs::mount' do
  let(:title) { 'namevar' }
  let(:params) do
  { 'server': 'oh',
    'share': '/tmp',
  } end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os.include?('windows')
        it { is_expected.to compile.with_all_deps }
      else
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
