#name 'ccs receipt'
#description 'Deploys ccs per specs'

include_recipe "apt"
include_recipe "nginx"

package "nginx"
package "monit"
package "libnet-ssleay-perl"
package "libjson-perl"
package "libfcgi-perl"
package "libfcgi-procmanager-perl"

#cgiproxy_archive = '/var/chef/cache/cgiproxy-archive.tar.gz'
#remote_file cgiproxy_archive do
#    source "http://www.jmarshall.com/tools/cgiproxy/releases/cgiproxy.2.1.8.tar.gz"
#    mode "0644"
#end
#
directory "/opt/cgiproxy" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

cookbook_file "/opt/cgiproxy/nph-proxy.cgi" do
    source 'nph-proxy.cgi'
    mode "0755"
end

#
#
#execute 'untar-cgiproxy' do
#  cwd '/opt/cgiproxy'
#  command 'tar -xzf ' + cgiproxy_archive
#end
#
cookbook_file "/opt/cgiproxy/cgiproxy.patch" do
    source 'cgiproxy.patch'
    mode "0644"
end

execute 'configure-cgiproxy' do
  cwd '/opt/cgiproxy'
  command 'patch nph-proxy.cgi < cgiproxy.patch'
end

service "cgiproxy" do
  supports :restart => true, :start => true, :stop => true
  action :nothing
end

cookbook_file "/etc/init.d/cgiproxy" do
    source 'cgiproxy.init'
    mode "0755"
#    notifies :enable, "service[cgiproxy]"
    notifies :start, "service[cgiproxy]"
end

directory "/etc/nginx/ssl" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/etc/nginx/ssl/server.key" do
  source "ssl/server.key"
  owner "root"
  group "root"
  mode "0600"
end

cookbook_file "/etc/nginx/ssl/server.crt" do
  source "ssl/server.crt"
  owner "root"
  group "root"
  mode "0600"
end

directory "/var/www/nginx-default" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

execute 'touchindex' do
  command 'touch /var/www/nginx-default/index.html'
end


template "/etc/nginx/sites-enabled/default" do
    source 'nginx_default.erb'
    notifies :reload, "service[nginx]"
end

service "monit" do
  action [:enable, :start]
  supports [:start, :restart, :stop]
end

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, "service[monit]", :delayed
end

