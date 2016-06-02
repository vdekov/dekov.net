# dekov.net Virtual Box

1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Download and install [Vagrant](https://www.vagrantup.com/downloads.html)
3. `git clone https://github.com/vdekov/dekov.net.git && cd dekov.net`
4. Generate SSL Certificate into the configs/ssl folder. Execute the following commands sequenty:
   - Create a private server key: `sudo openssl genrsa -des3 -out server.key 2048`
   - Create a certificate signing request: `sudo openssl req -new -key server.key -out server.csr`
   - Remove the passphrase: `sudo cp server.key server.key.org && sudo openssl rsa -in server.key.org -out server.key`
   - Sign the SSL Certificate: `sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt`
5. `vagrant up`
6. You can login into the virtual box with `vagrant ssh` and to start all services with the `box_start` command.
7. Open `http://192.168.33.10` on your preffered browser.