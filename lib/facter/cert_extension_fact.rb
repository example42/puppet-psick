Facter.add(:cert_extension) do
  setcode do
    require 'openssl'
    require 'puppet'
    require 'puppet/ssl/oids'

    # set variables
    extension_hash = {}
    certdir = Puppet.settings[:certdir]
    certname = Puppet.settings[:certname]
    certificate_file = "#{certdir}/#{certname}.pem"
    # get puppet ssl oids
    oids = {}
    Puppet::SSL::Oids::PUPPET_OIDS.each do |o|
      oids[o[0]] = o[1]
    end

    # read the certificate
    cert = OpenSSL::X509::Certificate.new File.read certificate_file

    # cert extensions differs if we run via agent (numeric) or as test (names)
    cert.extensions.each do |extension|
      case extension.oid.to_s
      when %r{^1\.3\.6\.1\.4\.1\.34380\.1\.1}
        short_name = oids[extension.oid]
        value = extension.value[2..-1]
        extension_hash[short_name] = value unless short_name == 'pp_preshared_key'
      when %r{^pp_}
        short_name = extension.oid
        value = extension.value[2..-1]
        extension_hash[short_name] = value unless short_name == 'pp_preshared_key'
      end
    end

    extension_hash
  end
end

