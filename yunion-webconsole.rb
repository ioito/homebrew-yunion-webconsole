class YunionWebconsole < Formula
  desc "Yunion Cloud WebConsole Controller server"
  homepage "https://github.com/yunionio/onecloud.git"
  version_scheme 1
  head "https://github.com/yunionio/onecloud.git",
    :branch      => "master"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    (buildpath/"src/yunion.io/x/onecloud").install buildpath.children
    cd buildpath/"src/yunion.io/x/onecloud" do
      system "make", "GOOS=darwin", "cmd/webconsole"
      bin.install "_output/bin/webconsole"
      prefix.install_metafiles
    end

    (buildpath/"webconsole.conf").write webconsole_conf
    etc.install "webconsole.conf"
  end

  def post_install
    (var/"log/webconsole").mkpath
  end

  def webconsole_conf; <<~EOS
  region = 'Yunion'
  address = '127.0.0.1'
  port = 8282
  auth_uri = 'https://127.0.0.1:35357/v3'
  admin_user = 'sysadmin'
  admin_password = 'sysadmin'
  admin_tenant_name = 'system'
  enable_ssl = false
  ssl_certfile = '/opt/yunionsetup/config/keys/webconsole/webconsole.crt'
  ssl_keyfile = '/opt/yunionsetup/config/keys/webconsole/webconsole.key'
  ssl_ca_certs = '/opt/yunionsetup/config/keys/webconsole/ca.crt'
  EOS
  end

  def caveats; <<~EOS
    brew services start yunion-webconsole
    source #{etc}/keystone/config/rc_admin
    climc service-create --enabled log webconsole
    climc endpoint-create --enabled webconsole Yunion public http://127.0.0.1:8282
    climc endpoint-create --enabled webconsole Yunion internal http://127.0.0.1:8282
    climc endpoint-create --enabled webconsole Yunion admin http://127.0.0.1:8282
  EOS
  end


  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>RunAtLoad</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/webconsole</string>
        <string>--conf</string>
        <string>#{etc}/webconsole.conf</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/webconsole/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/webconsole/output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "false"
  end
end
