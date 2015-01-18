#
# Cookbook Name:: xigpi
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'monit-ng'

# TODO: Ensure default user 'PI' is installed

package "git" do
 action :install
end

if node["platform"] == "raspbian"
	# Install the RaspberryPi Harddware Watchdog facilitiy
	package "watchdog" do
	  action :install
	end

	# Enable watchdog kernel module
	bash "modprobe bcm2708_wdog" do
	  code "modprobe bcm2708_wdog"
	  not_if "lsmod |grep bcm2708_wdog"
	end

	# Add watchdog kernel module to /etc/modules
	bash "install bcm2708_wdog in /etc/modules" do
	  code "echo 'bcm2708_wdog' >> /etc/modules"
	  not_if "grep '^bcm2708_wdog$' /etc/modules"
	end
end

# Disable Swap - because it hates on SD cards
bash "Disable Swap" do
  code "dphys-swapfile swapoff; dphys-swapfile uninstall; update-rc.d dphys-swapfile remove;"
  only_if "grep ^/var/swap /proc/swaps"
end

# TODO: Need to copy SSH key to /home/pi/.ssh/authorized_keys

# Install collectd package and configure it
package "collectd" do
  action :install
end

service "collectd" do
  supports :start => true, :stop => true, :restart => true
  action :enable
end

cookbook_file "collectd.conf" do
  path "/etc/collectd/collectd.conf"
  owner "root"
  group "root"
  action :create
  notifies :restart, "service[collectd]", :immediately
end

# TODO: Need to create templatized config for XigPi

# Get XigPi code from github
git "/opt/xigpi" do
  repository 'https://github.com/djsplice/XigPi.git'
  revision "master"
  action :checkout
end

template "/opt/xigpi/settings.json" do
  source "xigpi-settings-json.erb"
  owner "root"
  group "root"
  variables ({
    :port => node[:xigpi][:port],
    :baud => node[:xigpi][:baud]
  })
end

template "/opt/xigpi/xig_config_default.py" do
  source "xig_config_default.py.erb"
  owner "root"
  group "root"
end

# XigPi Starup Script
cookbook_file "xigpi.sh" do
  path "/opt/xigpi/xig.sh"
  owner 'root'
  group 'root'
  action :create
end

# XigPi Monit Service Check
monit_check 'xigpi' do
  check_id '/var/tmp/xigpi.pid'
  start_as 'root'
  start '/opt/xigpi/xig.sh start'
  stop '/opt/xigpi/xig.sh stop'
  tests [
    {
      'condition' => '5 restarts with 5 cycles',
      'action'    => 'timeout'
    },
    {
      'condition' => 'cpu is greater than 80% for 3 cycles',
      'action'    => 'restart'
    },
    {
      'condition' => 'mem > 50 MB for 3 cycles',
      'action'    => 'restart'
    },
  ]
end

# Install and configure the AutoSSH program to enable secure communication back to LMNT.CO
package "autossh" do
  action :install
end

# Phonehome SSH Key
cookbook_file "phonehome.key" do
  path "/home/pi/.ssh/phonehome.key"
  owner "pi"
  group "pi"
  mode '04000'
  action :create
end

# Phonehome Startup Script
cookbook_file "phonehome.sh" do
  path "/opt/phonehome/phonehome.sh"
  owner 'root'
  group 'root'
  action :create
end

## Phone Home Monit Service
monit_check 'autossh' do
  check_id '/var/tmp/phonehome.pid'
  start_as 'root'
  start '/opt/phonehome/phonehome.sh start'
  stop '/opt/phonehome/phonehome.sh stop'
  tests [
    {
      'condition' => '5 restarts with 5 cycles',
      'action'    => 'timeout'
    },
  ]
end
