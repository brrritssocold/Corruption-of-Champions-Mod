This directory contains scripts for CI builds

## Vagrant

If you have vagrant and virtualbox installed, you can test the scripts in a local VM.
This setup is intended to troubleshoot issues with package installations and configuration.
The VM can be used to test code if you do not wish to install the tools on the host, expect a performance penalty for running in a VM.

Use `vagrant up` to start a vm, `vagrant destroy -f` to stop and delete it.
Enter the VM with `vagrant ssh` press `ctrl-d` or type `exit` to leave the VM session.


You can run the script with `/vagrant/build-test.sh`
