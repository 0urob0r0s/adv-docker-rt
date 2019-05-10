# adv-docker-rt

[RT](https://www.bestpractical.com/rt/), or Request Tracker, is a issue tracking system. Currently build RT lastest (4.4.x).

## Requirements



## Usage

To run docker-rt (change to <full path> to the location of the files specified above):

        docker run -ti -p 443:443 -e RT_HOSTNAME=rt.example.com -e RT_RELAYHOST=mail.example.com -v /<full path>/docker-rt/files:/data --name rt -d reuteras/docker-rt

* `-e RT_HOSTNAME=<RT server hostname>`
* `-e RT_RELAYHOST=<Postfix relay host>`


## Build




## Install

In my environment I still use an vm to run Postgresql. Because of that I haven't scripted any default setup to automatically use a linked database container. Something like the following should help you get started.

    # Change mysecretpassword to something better
    docker run --name postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
    docker inspect postgres | grep IPAddress
    # edit RT_SiteConfig.pm and insert the IP Address
    docker run -ti -p 443:443 -e RT_HOSTNAME=servername -e RT_RELAYHOST=servername -v $(pwd)/files:/data --name rt -d reuteras/docker-rt
    docker exec -ti rt /bin/bash
    # in the container
    cd /tmp/rt/rt-4.4.*
    make initdb
    # enter password from step one
    exit

## TODO
Lots of things.

* Solution for adding plugins

