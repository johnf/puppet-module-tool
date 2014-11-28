def stub_repository_read(code, body)
  kind = Net::HTTPResponse.send(:response_class, code.to_s)
  response = kind.new('1.0', code.to_s, 'HTTP MESSAGE')
  response.stubs(:read_body).returns(body)
  Puppet::Module::Tool::Repository.any_instance.stubs(:read_contact).returns(response)
end

def stub_installer_read(body)
  Puppet::Module::Tool::Applications::Installer.any_instance.stubs(:read_match).returns(body)
end

def stub_exploder_find(user, name, version)
  uri = "http://forge.example.com/users/#{user}/modules/#{name}/releases/find.json"
  body = <<-EOF
    {"file": "/system/releases/#{user[0]}/#{user}/#{user}-#{name}-#{version}.tar.gz", "version": "#{version}"}
  EOF
  Puppet::Module::Tool::Applications::Exploder.any_instance.stubs(:read_url).with(uri).returns(body)
end

def stub_exploder_fetch(user, name, version)
  body = File.read("#{user}-#{name}/pkg/#{user}-#{name}-#{version}.tar.gz")
  uri = "http://forge.example.com/system/releases/#{user[0]}/#{user}/#{user}-#{name}-#{version}.tar.gz"
  Puppet::Module::Tool::Cache.any_instance.stubs(:read_retrieve).with(uri).returns(body)
end

def stub_cache_read(body)
  Puppet::Module::Tool::Cache.any_instance.stubs(:read_retrieve).returns(body)
end

def stub_uri_read(url, code, body)
  kind = Net::HTTPResponse.send(:response_class, code.to_s)
  response = kind.new('1.0', code.to_s, 'HTTP MESSAGE')
  response.stubs(:read_body).returns(body)
  Puppet::Module::Tool::Repository.any_instance.stubs(:read_contact).returns(response)
end
