# PROVISION THE DATABASE
for i in {1..15};
do 
    PROJECT=fuse-user$i
    oc project $PROJECT

    # oc delete all -l app=postgresql-persistent -n $PROJECT
    # oc delete pvc postgresql -n $PROJECT
    # oc delete secret postgresql -n $PROJECT

    oc new-app --template=postgresql-persistent --param=POSTGRESQL_PASSWORD=redhat --param=POSTGRESQL_USER=redhat --param=POSTGRESQL_DATABASE=sampledb -n $PROJECT;
done

# POPULATE THE DATABASE
for i in {1..15};
do 
    oc project fuse-user$i

    POD_POSTGRESQL=$(oc get po | grep postgresql | grep -v deploy | awk '{print $1}')
    oc exec -it $POD_POSTGRESQL -- bash -c 'psql -U redhat -d sampledb -c "CREATE TABLE users(id serial PRIMARY KEY,name VARCHAR (50),phone VARCHAR (50),age integer);"'
    oc exec -it $POD_POSTGRESQL -- bash -c 'psql -U redhat -d sampledb -c "CREATE TABLE orders(id serial PRIMARY KEY, user_id INT, name VARCHAR (50),price decimal(12,2), CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id));"'

    oc exec -it $POD_POSTGRESQL -- bash -c "psql -U redhat -d sampledb -c \"INSERT INTO users(name, phone, age) VALUES  ('Rodrigo Ramalho', '(11) 95474-8099', 30);INSERT INTO users(name, phone, age) VALUES  ('Thiago Araki', '(11) 95474-8099', 31);INSERT INTO users(name, phone, age) VALUES  ('Gustavo Luszczynski', '(61) 95474-8099', 29);INSERT INTO users(name, phone, age) VALUES  ('Rafael Tuelho', '(11) 95474-8099', 55);INSERT INTO users(name, phone, age) VALUES  ('Elvis', '(61) 95474-8099', 36);\""

    oc exec -it $POD_POSTGRESQL -- bash -c "psql -U redhat -d sampledb -c \"INSERT INTO orders(name, price, user_id) VALUES  ('Fedora Hat', '10', 1);INSERT INTO orders(name, price, user_id) VALUES  ('RHEL', '15', 1);INSERT INTO orders(name, price, user_id) VALUES  ('3Scale', '5', 1);INSERT INTO orders(name, price, user_id) VALUES  ('Fuse', '25', 1);INSERT INTO orders(name, price, user_id) VALUES  ('AMQ', '25', 1);INSERT INTO orders(name, price, user_id) VALUES  ('DATAGRID', '35', 1);INSERT INTO orders(name, price, user_id) VALUES  ('Fedora Hat', '10', 2);INSERT INTO orders(name, price, user_id) VALUES  ('RHEL', '15', 2);INSERT INTO orders(name, price, user_id) VALUES  ('RHEL', '15', 3);\""
done

# ORDER REST
for i in {1..15};
do 
    oc project fuse-user$i
    ./deploy-ocp.sh
    oc create route edge --service=orders-rest
done

# MISSING STEP - Install 3Scale Operator via script
# https://console-openshift-console.apps.cluster-latam-1287.latam-1287.sandbox1545.opentlc.com/operatorhub/subscribe?pkg=3scale-operator&catalog=redhat-operators&catalogNamespace=openshift-marketplace&targetNamespace=3scale-user11

THREESCALE_PROJECT="apim"
oc new-project $THREESCALE_PROJECT

oc create secret docker-registry threescale-registry-auth \
   --docker-server=registry.redhat.io \
   --docker-username="123123|YOUR-USER-NAME" \
   --docker-password="GENERATED-JWT"

oc create -f aws-auth.yaml -n $THREESCALE_PROJECT
oc create -f system-seed.yaml -n $THREESCALE_PROJECT
oc create -f apimanager.yaml -n $THREESCALE_PROJECT