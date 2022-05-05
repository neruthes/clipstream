# Clipstream


## Introduction

A very simple tool for caching clips in your scripts from stdin.

```
cat /path/to/file.txt | pushclip push
```


## Deployment

### Installation

Clone the repository and run:

```
sudo make install
```

### Configuration

**Nginx**: Refer to the `/conf/clipstream.nginx.conf` file.

Notes:

- Configuring fastcgi was difficult so [syscgijs](https://github.com/neruthes/syscgijs) is used as the CGI solution in the sample Nginx config. You may use any other CGI solution if you know how to configure it.

### Online Demo

Visit the [demo](https://clipstream.neruthes.xyz:2096/www/view.html?token=test-fe8cabd01f8cf01e).


## Copyright

Copyright (c) 2022 Neruthes.

Published with [GNU GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).
