#!/bin/bash
dbip=10.1.1.1
webip=10.2.20.11
docker run -d -e  "DB_URL=jdbc:mysql://$dbip:3306/yscheduler?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&noAccessToProcedureBodies=true&socketTimeout=10000&connectTimeout=10000" -e "DB_USER=yscheduler" -e "DB_PASSWORD=test" -e "DOMAIN_NAME=$webip:9999" -p 9999:8080 -v /dianyi/log:/dianyi/log -v /dianyi/fileServer:/dianyi/fileServer scheduler-web:0.6.3.3

