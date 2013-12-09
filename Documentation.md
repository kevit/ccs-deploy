##Documentation

>  You should deploy web server with nginx at hosting example.com

Here was used a nginx and hostname playbook's

```
Cheffile
cookbook 'nginx', :git => 'git://github.com/opscode-cookbooks/nginx.git'
cookbook 'hostname', :git => 'https://github.com/franco/chef-hostname' 
```

Hostname settled in vagrant config, node/vagrant.json and
attributes/default.rb

```
default['hostname']['set_fqdn']= "example.com"
```


All deployment will be done by ccs-deploy cookbook based in
site-cookbooks


> which has cgiproxy launched in fast-cgi mode (Cgiproxy
> Link)[http://www.jmarshall.com/tools/cgiproxy/]

Here is a two task: getting a cgiproxy and starting as fastcgi.
Unfortunately, Great Singapore Firewall ungzip 
archive, but not gzipping back and I spend some time to understand why
code below not working well.

```
$file /var/chef/cache/cgiproxy-archive.tar.gz
/var/chef/cache/cgiproxy-archive.tar.gz: POSIX tar archive
```

That was really unexpected and I punished to use a downloaded file

```
 14 #cgiproxy_archive = '/var/chef/cache/cgiproxy-archive.tar.gz'
 15 #remote_file cgiproxy_archive do
 16 #    source
"http://www.jmarshall.com/tools/cgiproxy/releases/cgiproxy.2.1.8.tar.gz"
 17 #    mode "0644"
 18 #end
 19 #

 20 directory "/opt/cgiproxy" do
 21   owner 'root'
 22   group 'root'
 23   mode '0755'
 24   action :create
 25   recursive true
 26 end
 27
 28 cookbook_file "/opt/cgiproxy/nph-proxy.cgi" do
 29     source 'nph-proxy.cgi'
 30     mode "0755"
 31 end
```

Here is a running of cgiproxy service part, I still have no idea why
enable of service not working well, maybe I should read documentation

```
 49
 50 service "cgiproxy" do
 51   supports :restart => true, :start => true, :stop => true
 52   action :nothing
 53 end
 54
 55 cookbook_file "/etc/init.d/cgiproxy" do
 56     source 'cgiproxy.init'
 57     mode "0755"
 58 #    notifies :enable, "service[cgiproxy]"
 59     notifies :start, "service[cgiproxy]"
 60 end
``` 

Also we need some dependencies what could badly affect portability and
should be checked additionally

```
  9 package "libnet-ssleay-perl"
 10 package "libjson-perl"
 11 package "libfcgi-perl"
 12 package "libfcgi-procmanager-perl"
```


> You should remove headers with X-Frame-Options on cgiproxy level and
ban javascript launching. 

I checked source of cgiproxy and prepare a patch file what doing needed
settings:

```
 40 cookbook_file "/opt/cgiproxy/cgiproxy.patch" do
 41     source 'cgiproxy.patch'
 42     mode "0644"
 43 end
 44
 45 execute 'configure-cgiproxy' do
 46   cwd '/opt/cgiproxy'
 47   command 'patch nph-proxy.cgi < cgiproxy.patch'
 48 end
```

> As a result proxy should be available on http://example.com/proxy and
work in iframe with any sites (you may use google.com and ya.ru to
test it)

Here is a deploy of nginx congfig:

```
 96 template "/etc/nginx/sites-enabled/default" do
 97     source 'nginx_default.erb'
 98     notifies :reload, "service[nginx]"
 99 end
```



Additional requirements:

> Implement https support (on basis of selfsubscribed certificate)

Certificate was prepared and this code deploy a cert to server. I
suppose data-bags will be more secure solution, but I still short in
time to implement

```
 62 directory "/etc/nginx/ssl" do
 63   owner 'root'
 64   group 'root'
 65   mode '0755'
 66   action :create
 67 end
 68
 69 cookbook_file "/etc/nginx/ssl/server.key" do
 70   source "ssl/server.key"
 71   owner "root"
 72   group "root"
 73   mode "0600"
 74 end
 75
 76 cookbook_file "/etc/nginx/ssl/server.crt" do
 77   source "ssl/server.crt"
 78   owner "root"
 79   group "root"
 80   mode "0600"
 81 end
```

> Connect nginx and cgiproxy through unix socket

Here is a two part: running a cgiproxy with  start-fcgi parameter and
configure a nginx part to use fastcgi

nginx_default
```
location /proxy/ {
    include       fastcgi_params;
    fastcgi_pass  unix:/tmp/cgiproxy.fcgi.socket;
}
```


>  Write init script and upstart job that allow start, stop and
restart proxy (not nginx)
Both scripts in files directory

>  Implement possibility of monitoring by means of monit

Monit configured to monitor system, cgiproxy and nginx and running on
port 2812

```
101 service "monit" do
102   action [:enable, :start]
103   supports [:start, :restart, :stop]
104 end
105
106 template "/etc/monit/monitrc" do
107   owner "root"
108   group "root"
109   mode 0700
110   source 'monitrc.erb'
111   notifies :restart, "service[monit]", :delayed
112 end
```

>  Set up a chef соokbook that will allow deploy
nginx+proxy+init+configs automatically to any linux server (including
all dependencies)
Chef cookbook already prepared. Most of things should work on any
servers, but have some limitations in portability.


>6. Test this solution using apache benchmark and give an account of
the results. What optimizations can you offer to improve the results?

Results placed into ab_testing file
