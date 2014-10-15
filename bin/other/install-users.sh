#!/bin/bash
groupadd -g 407 web
useradd -g web -u 1000 -d /web nsadmin
useradd -g web -u 1002 -d /web/service-phgt-0 service-phgt-0
