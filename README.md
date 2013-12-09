## Content

- theory file contain a questionary
- ab_testing file contain a test results
- [Http link to cgiproxy](http://example.com/proxy)
- [Https link to cgiproxy](https://example.com/proxy)
- [Monit](http://example.com:2812)

## Prerequests
- rvm
- vagrant 1.3

##Installation

```
rvm use 1.9.2@chief --create
gem install bundler
bundle install
vagrant box add wheezy-chef http://vagrantboxes.footballradar.com/wheezy64.box
librarian-chef install
vagrant up
sudo echo "192.168.33.13 example.com" >> /etc/hosts
```


## Bugs and issues
1. not fully portable between different linux distributions
2. not used data-bags for ssl certs
3. http/https proxy not working well, since $RUNNING_ON_SSL_SERVER
   option in cgiproxy possibly have a bug
4. upstart script is present (files/cgiproxy.upstart), but not tested
5. cgiproxy running with uid 0 (insecure)

