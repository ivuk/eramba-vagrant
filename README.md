eramba-vagrant
==============
A Vagrantfile and an Ansible playbook for provisioning an
[Eramba](http://www.eramba.org/) installation.

It expects you to have downloaded Eramba from the website, so there should be
a zip file named `eramba_v2.zip` in the root directory of this Git repository.

In case you don't feel like installing Ansible just for running this one
instance of `vagrant up`, there's a shell script which can also be used
for provisioning, provided you edit the Vagrantfile accordingly. Note that the
shell script lacks the setting up of the cron tasks.

Once the VM is ready, you can access it via `vagrant ssh`, and the application
itself is available by visiting the `http://localhost:8080` URL.

Make sure you edit the database parameters and the timezone in the shell script
or in the `provisioning/group_vars/all` file.
