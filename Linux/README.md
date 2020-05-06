# GossAudit

A minimal shell script provided by Rackspace to audit Linux Server configuration to ensure they are ready for enrollment automation.

**No changes / installations are performed as part of this script. It is read-only.**

## Prerequisites

- Supported Linux server distribution
- Bash version 4.0.0+


## List of checks performed:

- Operating system is eligible for Rackspace Linux support
- Operating system can resolve Rackspace service hostnames
- All users have a login shell configured
- Verifies Red Hat Enterprise Linux systems can retrieve update packages

## Usage
Download and execute the shell script GossAudit.sh.
```bash
curl -O https://raw.githubusercontent.com/rackerlabs/GossAudit/master/GossAudit.sh
bash GossAudit.sh
```

## Recommendations

Output from the script will look like the following:

```bash
[root@45e11e4385c6 ~]# bash /scripts/GossAudit.sh
WARNING: All users should have a login shell configured
DNS check: OK
Yum check: OK
[root@45e11e4385c6 ~]# echo $?
1
```

In this case the device is not ready for enrollment. The script exited with status code 1 due to a user on the system not having a defined login shell.

When a device is ready for enrollment, the script will return 0:

```bash
[root@5e8d9e03ec00 ~]# bash /scripts/GossAudit.sh
User shell check: OK
DNS check: OK
Yum check: OK
[root@5e8d9e03ec00 ~]# echo $?
0
```

## Issues
If you have any technical issues with the module, you can create an issue using the below link:

https://github.com/rackerlabs/GossAudit/issues/new

Any other queries should be directed towards your Rackspace account team.
