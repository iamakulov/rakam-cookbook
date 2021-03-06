
bash "clean-setup" do
  code <<-EOH
    cd /home/webapp
    su webapp -l -c 'rm -rf ./presto'
    su webapp -l -c 'rm -rf ./presto-streamer'
  EOH
end

directory "/home/webapp/presto-streamer" do
  owner "webapp"
  group "webapp"
  mode 0755
end
directory "/home/webapp/presto-streamer/etc" do
  owner "webapp"
  group "webapp"
  mode 0755
end
template "/home/webapp/presto-streamer/etc/jvm.config" do
  source "collector/jvm.config.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end
template "/home/webapp/presto-streamer/etc/config.properties" do
  source "collector/config.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end
template "/home/webapp/presto-streamer/etc/log.properties" do
  source "collector/log.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end
template "/home/webapp/presto-collector-heartbeat" do
  source "collector/presto-collector-heartbeat.sh"
  owner "webapp"
  group "webapp"
  mode 0775
end



directory "/home/webapp/presto" do
  owner "webapp"
  group "webapp"
  mode 0755
end
directory "/home/webapp/presto/plugin" do
  owner "webapp"
  group "webapp"
  mode 0755
end
directory "/home/webapp/presto/plugin/presto-rakam-udf" do
  owner "webapp"
  group "webapp"
  mode 0755
end
directory "/home/webapp/presto/plugin/presto-rakam-raptor" do
  owner "webapp"
  group "webapp"
  mode 0755
end

directory node['data-dir'] do
  owner "webapp"
  group "webapp"
  mode 0755
end

directory "/home/webapp/presto/etc" do
  owner "webapp"
  group "webapp"
  mode 0755
end
directory "/home/webapp/presto/etc/catalog" do
  owner "webapp"
  group "webapp"
  mode 0755
end

template "/home/webapp/presto/etc/config.properties" do
  source "presto/config.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end

template "/home/webapp/presto/etc/logging.properties" do
  source "presto/logging.properties.erb"
  owner "webapp"
  group "webapp"
  variables ({ :version => `bash -c "if [ -z ${PRESTO_RAKAM_UDF_VERSION+x} ]; then curl -s https://api.bintray.com/packages/buremba/maven/presto-rakam-udf | jq -r '.latest_version'; else echo $PRESTO_RAKAM_UDF_VERSION; fi"` })
  mode 0644
end

template "/home/webapp/presto-server-heartbeat" do
  source "presto/presto-server-heartbeat.sh"
  owner "webapp"
  group "webapp"
  mode 0775
end

template "/home/webapp/presto/etc/node.properties" do
  source "presto/node.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end

template "/home/webapp/presto/etc/jvm.config" do
  source "presto/jvm.config.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end

template "/home/webapp/presto/etc/log.properties" do
  source "presto/log.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end

template "/home/webapp/presto/etc/catalog/external.properties" do
  source "presto/catalog/external.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end

template "/home/webapp/presto/etc/catalog/rakam_raptor.properties" do
  source "presto/catalog/rakam_raptor.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0755
end

presto_download_address = "https://repo1.maven.org/maven2/com/facebook/presto/presto-server/#{node['presto_version']}/presto-server-#{node['presto_version']}.tar.gz"
presto_streamer_download_address = "https://s3.amazonaws.com/rakam-private-code/rakam-presto-builds/#{node['presto_version']}/latest.tar.gz"

bash "download-and-setup-presto" do
  code <<-EOH
    cd /home/webapp
    su webapp -l -c 'wget -N #{presto_download_address}'
    su webapp -l -c 'tar -zxvf latest.tar.gz && mv collector-*/* ./presto-streamer/ && rm -r collector-* && rm latest.tar.gz'
    su webapp -l -c 'wget -N #{presto_streamer_download_address}'
    su webapp -l -c 'tar -zxvf presto-server-#{node['presto_version']}.tar.gz'
    su webapp -l -c 'rm -rf presto/bin && cp -r presto-server-#{node['presto_version']}/bin/ presto/'
    su webapp -l -c 'rm -rf presto/lib && cp -r presto-server-#{node['presto_version']}/lib/ presto/'
    su webapp -l -c 'PRESTO_UDF_VERSION="$(if [ -z #{node['rakam_presto_udf_version']} ]; then curl -s https://api.bintray.com/packages/buremba/maven/presto-rakam-udf | jq -r '.latest_version'; else echo #{node['rakam_presto_udf_version']}; fi)" && wget -nc "https://dl.bintray.com/buremba/maven/com/facebook/presto/presto-rakam-udf/${PRESTO_UDF_VERSION}/presto-rakam-udf-${PRESTO_UDF_VERSION}.zip" && unzip -o "presto-rakam-udf-${PRESTO_UDF_VERSION}.zip" && rm -rf ./presto/plugin/presto-rakam-udf && mkdir ./presto/plugin/presto-rakam-udf && mv presto-rakam-udf-${PRESTO_UDF_VERSION}/* ./presto/plugin/presto-rakam-udf; test ${PIPESTATUS[0]} -eq 0'
    su webapp -l -c 'RAPTOR_VERSION="$(if [ -z #{node['rakam_presto_raptor_version']} ]; then curl -s https://api.bintray.com/packages/buremba/maven/presto-rakam-raptor | jq -r '.latest_version'; else echo #{node['rakam_presto_raptor_version']}; fi)" && wget -nc "https://dl.bintray.com/buremba/maven/com/facebook/presto/presto-rakam-raptor/${RAPTOR_VERSION}/presto-rakam-raptor-${RAPTOR_VERSION}.zip" && unzip -o "presto-rakam-raptor-${RAPTOR_VERSION}.zip" && rm -rf ./presto/plugin/presto-rakam-raptor && mkdir ./presto/plugin/presto-rakam-raptor && mv presto-rakam-raptor-${RAPTOR_VERSION}/* ./presto/plugin/presto-rakam-raptor; test ${PIPESTATUS[0]} -eq 0'
  EOH
end

bash "download-and-setup-presto-collector" do
  code <<-EOH
    cd /home/webapp
    su webapp -l -c 'wget -N #{presto_streamer_download_address}'
    su webapp -l -c 'tar -zxvf latest.tar.gz'
    su webapp -l -c 'mv collector-*/* ./presto-streamer/'
    su webapp -l -c 'rm -r collector-* && rm latest.tar.gz'
  EOH
end
