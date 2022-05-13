#!/opt/puppetlabs/puppet/bin/ruby
# Based on https://forge.puppet.com/gabe/set_noop version 1.1.6
require 'json'
require 'open3'
require 'puppet'

def set(truefalse)
  # Step one, decide on the correct path to the Puppet binary.
  puppet_command = if Facter.value(:os)['family'] == 'windows'
                     'C:/Program Files/Puppet Labs/Puppet/bin/puppet.bat'
                   else
                     '/opt/puppetlabs/puppet/bin/puppet'
                   end

  # Now, use Puppet itself to update its config with the proper value of noop
  cmd = [puppet_command, 'config', 'set', '--section', 'agent', 'noop', truefalse.to_s]
  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, _("stderr: ' #{stderr}') % { stderr: stderr }") if status != 0
  {
    'status' => stdout.strip,
    'result' => "Set noop = #{truefalse} in puppet.conf",
  }
end

# Find the desired setting from the JSON coming in over STDIN
params = JSON.parse(STDIN.read)
truefalse = params['setting']

# Run the command with the desired setting, and return the result
begin
  result = set(truefalse)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
