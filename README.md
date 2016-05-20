[![Circle CI](https://circleci.com/gh/versioneye/versioneye-security.svg?style=svg)](https://circleci.com/gh/versioneye/versioneye-security)

# VersionEye Security

This repo contains the security crawlers for [VersionEye](https://www.versioneye.com) written in ruby.

## Start the backend services for VersionEye

This project contains a [docker-compose.yml](docker-compose.yml) file which describes the backend systems
of VersionEye. You can start the backend systems like this:

```
docker-compose up -d
```

That will start:

 - MongoDB
 - RabbitMQ
 - ElasticSearch
 - Memcached

For persistence you should comment in and adjust the mount volumes in [docker-compose.yml](docker-compose.yml)
for MongoDB and ElasticSearch. If you are not interested in persisting the data on your host you can
let it untouched.

Shutting down the backend systems works like this:

```
docker-compose down
```

## Configuration

All important configuration values are read from environment variable. Before you start
VersioneyeCore.new you should adjust the values in [scripts/set_vars_for_dev.sh](scripts/set_vars_for_dev.sh)
and load them like this:

```
source ./scripts/set_vars_for_dev.sh
```

The most important env. variables are the ones for the backend systems, which point to MongoDB, ElasticSearch,
RabbitMQ and Memcached.

# Rake Tasks

Get a list of all rake tasks:

```
rake -T
```

Crawl for Java security vulnerabilities:

```
rake versioneye:crawl_java_security
```

## License

VersionEye-Core is licensed under the MIT license!

Copyright (c) 2016 VersionEye GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
