# XigPi-Solo

This cookbook supports both Knife Solo, and installation using TestKitchen on a local VM (site-cookbooks/xigpi).

It will install the [Xig Software ](http://www.faludi.com/projects/xbee-internet-gateway/) developed by Jordan Husney, Ted Hayes, and Rob Faludi. I had this running on a special piece of hardware, the [ConnectPort X2](http://www.digi.com/products/wireless-routers-gateways/gateways/connectportx2ese), but wanted a more cost effective solution. As the Xig software was written in python, I decided to get it running on a RaspberryPi.

This cookbook will do the following:
* Configure the RasperryPi
  * Install hardware watchdog
  * Disable Swap
* Install CollectD for stats reporting to Graphite
* Install and configure my modified version of Xig to use private REST endpoint instead of depending on iDigi Cloud
* Install Monit to manage the XigPi process
* Install AutoSSH to 'phone home'
* Install a monit config to manage the AutoSSH tunnel

## Supported Platforms

* RASPBIAN - Debian Wheezy (7.8)
* Testing on Ubuntu 14.04

## Attributes

We set a few default attributes, feel free to override.
```json
"xigpi": {
  "port": "8000",
  "baud": "115200"
},
"monit": {
  "config": {
    "listen": "0.0.0.0",
    "allow": "192.168.1.69",
    "mail_servers": [],
    "subscribers": []
  }
}
```

## Usage

1. Pull down the dependent cookbooks using berkshelf:
```
berks install
```
 * I had to fork the monit-ng as there were no overrides to exempt Mail config, which would prevent monit from starting.
1. Bootstrap your raspberry pi with chef-client
`knife solo prepare pi@raspberrypi`
1. Ensure you have set your nodes/[ip_address].json file correctly, add the default recipe, and monit-ng:
```json
{
    "run_list": [
      "recipe[monit-ng::default]",
      "recipe[xigpi::default]"
    ],
    "automatic": {
      "ipaddress": "192.168.1.72"
    }
}
```
1. Cook!
`knife solo cook -VV pi@192.168.1.72`

## License and Authors

Author:: Jeff Barrows (<barrows.jeff@gmail.com>)
