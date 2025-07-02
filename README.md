# Oracle migration using EDB Postgres AI Hybrid Manager (EDB HM)

This demo shows an example of how to migrate the Oracle 19c sample database `HRPLUS` from Oracle 19c to EDB Postgres Advanced Server using the EDB Postgres AI Hybrid Manager.
This demo will make use of the EDB EMEA SE Hybrid Manager available on https://

## Demo prep
> [!CAUTION]
> Preparation of this demo takes time! take AT LEAST 30 minutes to prepare the Oracle virtual machine!

### Pre-requisites
This demo has been deployed on a 2019 MacBook Pro with 12 CPUs and 16Gb of memory assigned to Docker.

To deploy this demo the following software needs to be installed in the PC from which you are going to deploy the demo:
- VirtualBox (https://www.virtualbox.org/)
- Vagrant (https://www.vagrantup.com/) with `vagrant-hosts`, `vagrant-reload` and `vagrant-env` plug-ins.
- A file called `.edb_subscription_token` with your EDB repository 2.0 token in your $HOME/token directory. This token can be found in your EDB account profile here: https://www.enterprisedb.com/accounts/profile

### Prepare Oracle installer files
This demo uses the [Oracle github repo](https://github.com/oracle/vagrant-projects/tree/main) to deploy a local Oracle 19c database using Vagrant. This demo script assumes that the repo has been cloned to a local directory `$HOME/oraclevagrant`. Please replace the value of `$ORACLE_VAGRANT_DIR` in `00-provision.sh` with the correct path you cloned this repo to.

Because we are deploying Oracle 19c, we need to download the Oracle database installer and store it on your filesystem according to (https://github.com/oracle/vagrant-projects/tree/main/OracleDatabase/19.3.0#getting-started).

### Provision the demo
Provision the demo using `00-provision.sh`.

After provisioning Oracle will be avialable on `localhost:1521'.

The Oracle defaults are described [here](https://github.com/oracle/vagrant-projects/tree/main/OracleDatabase/19.3.0#oracle-database-parameters). In the file `config/env.local` you can define a fixed password for the `oracle` user. In this demo this password is defined as `oracle`.

