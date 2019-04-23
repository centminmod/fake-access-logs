Fake access logs generated using [Fake Apache Log Generator](https://github.com/kiritbasu/Fake-Apache-Log-Generator). Used for benchmarking compressed access log processing through zcat, pzcat & zstdcat. Intended for zcat, pzcat & zstdcat processing of compressed access log benchmarking routine to be added to [centminmodbench.sh](http://bench.centminmod.com/) script. If you use log analysis tools like [ngxtop](https://community.centminmod.com/threads/ngxtop-real-time-metrics-for-nginx.285/), then you would need to use zcat to inspect and pipe to ngxtop many gz compressed Nginx access logs using zcat. So knowing how well your server can perform for zcat operations is important.

You can share your results in discussion thread [here](https://community.centminmod.com/threads/zcat-compressed-access-log-processing-benchmarks.14650/).

* `access_log_20180428-234724.log.gz` - 1 million line access log with 211MB uncompressed size and 41MB compressed size
* `access_log_20180429-005239.log.gz` - 1 million line access log with 211MB uncompressed size and 41MB compressed size
* `access_log_20180429-012648.log.gz` - 1 million line access log with 211MB uncompressed size and 41MB compressed size

```
ls -lah access_log_2018042*-*.log*  
-rw-r--r-- 1 root root 211M Apr 29 00:23 access_log_20180428-234724.log
-rw-r--r-- 1 root root  41M Apr 29 00:23 access_log_20180428-234724.log.gz
-rw-r--r-- 1 root root 211M Apr 29 01:26 access_log_20180429-005239.log
-rw-r--r-- 1 root root  41M Apr 29 01:26 access_log_20180429-005239.log.gz
-rw-r--r-- 1 root root 211M Apr 29 01:59 access_log_20180429-012648.log
-rw-r--r-- 1 root root  41M Apr 29 01:59 access_log_20180429-012648.log.gz
```

# Manual Command Line Tests

You can manually run a test to see how fast your server is able inspect a set of 3x gzip compressed access.log files which each contains 1 million lines of fake dummy generated HTTP requests and using `wc` command calculate the number of lines within that gzip compressed access.log. This will test the speed of the cpu in how fast it can uncompress on the fly the gzip compressed access logs and calculate the number of lines contained within the log files combined which should result in 3 million log lines calculated. It also tests the speed of your underlying disk system as well.

```
/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' zcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
```

output shows zcat took 4.15 seconds to process the 3 compressed access logs

```
/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' zcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
real: 4.15s user: 3.39s sys: 0.43s cpu: 92% maxmem: 1316 KB cswaits: 3
3000000
```

# Setup Multi-Threaded Pigz Zcat

If you have more than 3 cpu threads on system you can create multi-threaded version of zcat switching out single threaded gzip for multi-threaded pigz compression tool and create a `/usr/bin/pzcat` command using below code:

```
if [[ "$(nproc)" -ge '2' && ! -f /usr/bin/pzcat && -f /usr/bin/zcat && -f /usr/bin/pigz ]]; then \cp -af /usr/bin/zcat /usr/bin/pzcat; sed -i 's|exec gzip -cd|exec pigz -cd|' /usr/bin/pzcat; fi
```

In which case test command would be:

```
/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' pzcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
```

output shows multithreaded pzcat took 2.64 seconds to process the 3 compressed access logs

```
/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' pzcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
real: 2.64s user: 2.23s sys: 0.40s cpu: 99% maxmem: 1316 KB cswaits: 79180
3000000
```

# Scripted Tests

## Download test.sh directly:

```
curl -sL https://github.com/centminmod/fake-access-logs/raw/master/test.sh -o test.sh && chmod +x test.sh
./test.sh zcat
./test.sh pzcat
./test.sh zstdcat
./test.sh all
```

Or use `git clone`

```
yum -y install git-lfs
mkdir -p /root/tools
cd /root/tools
git clone https://github.com/centminmod/fake-access-logs
cd fake-access-logs
git lfs install
git lfs pull
git lfs ls-files
./test.sh
```

## To update the test.sh code when updates occur:

If you downloaded test.sh directly, change into directory where test.sh is located and run commands

```
cd /path/to/where/test.sh
rm -rf test.sh
curl -sL https://github.com/centminmod/fake-access-logs/raw/master/test.sh -o test.sh && chmod +x test.sh
```

If you installed via git clone

```
cd /root/tools/fake-access-logs
git stash
git pull
git lfs pull
```

## Command Usage Options

```
./test.sh 

./test.sh {zcat|pzcat|zstdcat}
```

## Examples

zcat test

```
./test.sh zcat
zcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
real: 2.65s user: 2.56s sys: 0.09s cpu: 99% maxmem: 1460 KB cswaits: 17
3000000
total 252M
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180428-234724.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180428-234724.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-005239.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-005239.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-012648.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-012648.log.zst
```

pzcat multi-threaded test

```
./test.sh pzcat
pzcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
real: 1.37s user: 1.82s sys: 0.21s cpu: 148% maxmem: 1460 KB cswaits: 44400
3000000
total 252M
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180428-234724.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180428-234724.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-005239.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-005239.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-012648.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-012648.log.zst
```

zstdcat test

```
./test.sh zstdcat
zstdcat access_log_20180428-234724.log.zst access_log_20180429-005239.log.zst access_log_20180429-012648.log.zst | wc -l
real: 5.82s user: 5.64s sys: 0.15s cpu: 99% maxmem: 3328 KB cswaits: 20229
3000000
total 252M
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180428-234724.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180428-234724.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-005239.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-005239.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-012648.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-012648.log.zst
```

run both zcat and pzcat and zstdcat tests using `all` flag

```
./test.sh all
downloading test access logs
download complete

zcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
real: 2.67s user: 2.56s sys: 0.10s cpu: 99% maxmem: 1460 KB cswaits: 19
3000000
total 252M
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180428-234724.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180428-234724.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-005239.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-005239.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-012648.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-012648.log.zst

pzcat access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz | wc -l
real: 1.34s user: 1.80s sys: 0.20s cpu: 149% maxmem: 1456 KB cswaits: 44412
3000000
total 252M
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180428-234724.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180428-234724.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-005239.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-005239.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-012648.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-012648.log.zst

zstdcat access_log_20180428-234724.log.zst access_log_20180429-005239.log.zst access_log_20180429-012648.log.zst | wc -l
real: 5.83s user: 5.66s sys: 0.13s cpu: 99% maxmem: 3328 KB cswaits: 20243
3000000
total 252M
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180428-234724.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180428-234724.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-005239.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-005239.log.zst
-rw-r--r-- 1 root root 41M Apr 23 02:38 access_log_20180429-012648.log.gz
-rw-r--r-- 1 root root 44M Apr 23 02:38 access_log_20180429-012648.log.zst
```