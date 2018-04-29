Fake access logs generated using [Fake Apache Log Generator](https://github.com/kiritbasu/Fake-Apache-Log-Generator). Used for benchmarking compressed access log processing through zcat. Intended for zcat compressed access log benchmarking routine to be added to [centminmodbench.sh](https://github.com/centminmod/centminmodbench/) script. If you use log analysis tools like [ngxtop](https://community.centminmod.com/threads/ngxtop-real-time-metrics-for-nginx.285/), then you would need to use zcat to inspect and pipe to ngxtop many gz compressed Nginx access logs using zcat. So knowing how well your server can perform for zcat operations is important.

* `access_log_20180428-234724.log.gz` - 1 million line access. with 211MB uncompressed size and 41MB compressed size

```
ls -alh access_log_20180428-234724.log*
-rw-r--r-- 1 root root 211M Apr 29 00:23 access_log_20180428-234724.log
-rw-r--r-- 1 root root  41M Apr 29 00:23 access_log_20180428-234724.log.gz
```

# Manual Command Line Tests

You can manually run a test to see how fast your server is able inspect a gzip compressed access.log which contains 1 million lines of fake dummy generated HTTP requests and using `wc` command calculate the number of lines within that gzip compressed access.log. This will test the speed of the cpu in how fast it can uncompress on the fly the gzip compressed access log and calculate the number of lines contained within the log file. It also tests the speed of your underlying disk system as well.

```
/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' zcat access_log_20180428-234724.log.gz | wc -l
```

# Setup Multi-Threaded Pigz Zcat

If you have more than 3 cpu threads on system you can create multi-threaded version of zcat switching out single threaded gzip for multi-threaded pigz compression tool and create a `/usr/bin/pzcat` command using below code:

```
if [[ "$(nproc)" -ge '2' && ! -f /usr/bin/pzcat && -f /usr/bin/zcat ]]; then \cp -af /usr/bin/zcat /usr/bin/pzcat; sed -i 's|exec gzip -cd|exec pigz -cd|' /usr/bin/pzcat; fi
```

In which case test command would be:

```
/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' pzcat access_log_20180428-234724.log.gz | wc -l
```

# Scripted Tests

