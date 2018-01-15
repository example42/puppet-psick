require 'spec_helper'
require 'yaml'
facts_yaml = File.dirname(__FILE__) + '/../fixtures/facts/spec.yaml'
facts = YAML.load_file(facts_yaml)

describe 'psick::users' do
  let(:facts) do
    facts
  end

  on_supported_os(facterversion: '2.4').select { |k, _v| k == 'redhat-7-x86_64' || k == 'ubuntu-16.04-x86_64' }.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(super())
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('psick::users') }

      context 'with defaults values' do
        describe 'Root user is not created'
        it { is_expected.not_to contain_user('root') }

        describe 'No users are created'
        it { is_expected.to have_user_resource_count(0) }

        describe 'Unmanaged users are not purged'
        it { is_expected.to have_psick__users__managed_resource_count(0) }
      end

      context 'with root_pw: set' do
        let(:params) do
          { root_pw: 'test_root_pw' }
        end

        describe 'Root user is created'
        it do
          is_expected.to contain_user('root').with(
            'password' => 'test_root_pw',
          )
        end
      end

      context 'with :delete_unmanaged set to true' do
        # it { pp catalogue.resources }  # Uncomment to dump the catalogue
        let(:params) do
          { delete_unmanaged: true }
        end

        describe 'Non-system users are purged'
        it do
          is_expected.to contain_resources('user').with(
            purge: true,
            unless_system_user: true,
          )
        end
      end

      context 'with :users_hash defined' do
        let(:params) do
          { 
            users_hash: {
              test_user1: {
                name: 'user1',
              },
              test_user2: {
                name: 'user2',
              },
            }
          }
        end

        it { is_expected.to have_user_resource_count(2) }
      end

      context('with :users_hash defined and module => psick') do
        let(:params) do
          { 
            users_hash: {
              test_user1: {
                name: 'user1',
              },
              test_user2: {
                name: 'user2',
              },
            }
          }
        end

        it { is_expected.to have_psick__users__managed_resource_count(2) }
      end

      context 'with invalid parameter values' do
        describe ':root_pw cannot be empty string'
          let(:params) do
            { root_pw: '' }
          end

          it { is_expected.to raise_error(Puppet::PreformattedError, /^Evaluation Error:.*/) }
      end
    end
  end
end
