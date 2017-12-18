## General
This repository store source code, deployment scripts are used for Challenge Web 500 - [WhiteHat Grand Prix 2017](https://ctftime.org/event/543) (a hacking contest).

### About ideas of the challenge
The challenge has two parts:
- Part 1: Exploit a RCE flaw in a Web app written in Perl
- Part 2: After getting RCE, reading source codes and breaking a crypto scheme written in Python (fake signature)

### Materials for players
 [Source Code](problem/src_009c5f7151bd16d9565da90324d6e12ca4d84550.zip)

## Deployment
```shell
sudo chmod +x ./install.sh
sudo ./install.sh
```

## Issues
In the competition, the organizer told me that they found that one team got the flag in an unexpected way: Privilege escalation.

Right after that I discovered the main problem was [CVE-2017-11610](https://github.com/Supervisor/supervisor/issues/964) in [supervisor](http://supervisord.org/). Supervisor is a process control system that I used to manage components of the challenge, so they can be rebooted automatically in case they are killed or are crashed. There are several causes for this flaw:
- Part 1 of this challenge allow remote code execution, then can access OS as a normal user
- The config file of supervisor can be read by anyone (permission 755) led to obtaining credentials of supervisor Web Manager
- The installed supervisor version is not the latest version. This supervisor is installed by command `sudo apt-get install supervisor` but I got version 3.2 (affected version), while the latest version is 3.3.3. You can test in Ubuntu 16.04.3 LTS

### Fixes 
- Prevent users from viewing other users' processes
- Prevent users from reading configuration files
- Re-install supervisor by `pip2 install supervisor`

## Author 
[linerd](https://github.com/linerd0196) & [everping](https://twitter.com/everping)
