include_recipe "nodejs::npm"

bash "download and build package" do
  code <<-EOH
    cd /home/webapp
    su webapp -l -c 'if cd rakam; then git pull; else git clone https://github.com/buremba/rakam.git && cd rakam; fi'
    su webapp -l -c 'cd rakam; mvn clean install -DskipTests && rm -r ../rakam-server && mv rakam/target/*-bundle/rakam-* ../rakam-server'
  EOH
end

template "/home/webapp/rakam-server/etc/config.properties" do
  source "config.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0644
end

template "/home/webapp/rakam-server/etc/log.properties" do
  source "log.properties.erb"
  owner "webapp"
  group "webapp"
  mode 0644
end