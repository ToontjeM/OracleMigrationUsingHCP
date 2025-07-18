# Oracle migration using EDB Postgres AI Hybrid Manager (EDB HM)

This demo shows an example of how to migrate the Oracle 21c sample database `HR` from Oracle 21c to EDB Postgres Advanced Server using the EDB Postgres AI Hybrid Manager.

This demo will make use of the EDB EMEA SE Hybrid Manager available on https://portal-se-emea.edbhcp.com

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
This demo uses the [Oracle github repo](https://github.com/oracle/vagrant-projects/tree/main) to deploy a local Oracle 21c database using Vagrant. This demo script assumes that the repo has been cloned to a local directory `$HOME/oraclevagrant`. Please replace the value of `$ORACLE_VAGRANT_DIR` in `00-provision.sh` with the correct path you cloned this repo to.

Because we are deploying Oracle 21c, we need to download the Oracle database installer and store it on your filesystem according to (https://github.com/oracle/vagrant-projects/tree/main/OracleDatabase/21.3.0#getting-started).

### Prepare the HM
- Create a machine user in your account, give him the `admin` role.
- In the project assign the machine user all roles (probably this is excessive), then create an access key for that user. (See https://www.enterprisedb.com/docs/edb-postgres-ai/hybrid-manager/using_hybrid_manager/using_the_api/access_key/)

Make sure you define the following variables before provisioning the demo:
- `export ACCESS_KEY=<your access key>`
- `export EDB_SUBSCRIPTION_TOKEN=<your repo 2.0 token>`
- `export PROJECT_NAME=<your project>`
These will be used in the provisioning scripts.

### Provision the demo
Provision the demo using `00-provision.sh`.

After provisioning an Oracle instance will be avialable on `localhost:1521' and a cluster called `migrationdemo` is created in your project.

The Oracle defaults are described [here](https://github.com/oracle/vagrant-projects/tree/main/OracleDatabase/21.3.0#oracle-database-parameters). In the file `config/env.local` you can define a fixed password for the `oracle` user. In this demo this password is defined as `oracle`. The password for user `hr` is `hr`.

For the migration user use `migrationuser` with password `migration`.

Superuser for the cluster is `edb-admin` with password `enterprisedb`.

