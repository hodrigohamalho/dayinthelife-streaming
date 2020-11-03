for i in {2..15};
do 
    oc project user$i
    oc new-app -f https://raw.githubusercontent.com/openshift/origin/master/examples/db-templates/postgresql-ephemeral-template.json --param=POSTGRESQL_USER=dbuser --param=POSTGRESQL_PASSWORD=password --param=POSTGRESQL_DATABASE=sampledb --param=POSTGRESQL_VERSION=latest -n user$i
    oc new-app s2i-fuse71-spring-boot-camel -p GIT_REPO=https://github.com/RedHatWorkshops/dayinthelife-integration -p CONTEXT_DIR=/projects/location-service -p APP_NAME=location-service -p GIT_REF=master -n user$i
done
