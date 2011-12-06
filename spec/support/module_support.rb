def stub_forge_module(user, name, version)
  release_name = "#{user}-#{name}-#{version}"
  full_name    = "#{user}-#{name}"

  module_fixture user, name, version
  app.build(full_name)

  stub_exploder_fetch user, name, version
  FileUtils.rm_rf(full_name)

  stub_exploder_find user, name, version
end


def module_fixture(user, name, version)
  dir = "#{user}-#{name}"
  FileUtils.mkdir dir
  FileUtils.cd dir do

    File.open("Modulefile", "w") do |f|
      f.puts <<-EOF
        name '#{user}-#{name}'
        version '#{version}'
      EOF
    end

    FileUtils.mkdir 'manifests'
    FileUtils.touch 'manifests/init.pp'

    modulefile_sum = `md5sum Modulefile`.strip
    init_sum =        `md5sum manifests/init.pp`.strip

    File.open("metadata.json", "w") do |f|
      f.puts <<-EOF
      {
        "version": "#{version}",
        "name": "#{user}-#{name}"
        "dependencies": [],
        "checksums": {
          "manifests/init.pp": "#{init_sum}",
          "Modulefile":        "#{modulefile_sum}"
        },
      }
      EOF
    end
  end
end
