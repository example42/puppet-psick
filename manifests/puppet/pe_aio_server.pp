# This class manages tp::test for a PE all in one server
#
class psick::puppet::pe_aio_server (
) {

  contain ::psick::puppet::pe_console
  contain ::psick::puppet::pe_puppetdb
  contain ::psick::puppet::pe_agent
  contain ::psick::puppet::pe_server

}
