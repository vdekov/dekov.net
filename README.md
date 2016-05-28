# dekov.net Virtual Box

1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Download and install [Vagrant](https://www.vagrantup.com/downloads.html)
3. `git clone https://github.com/vdekov/dekovnet-box.git`
4. `cd dekovnet-box && vagrant up`
5. You can login into the virtual box with `vagrant ssh` and to start all services with the `box_start` command.
6. Open `http://192.168.33.10` on your preffered browser.

## Generate SSL Certificates into the configs/ssl folder