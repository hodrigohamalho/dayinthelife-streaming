NUM_USERS=3
THREESCALE_PROJECT="apim"
ROUTE=$(oc get route console -n openshift-console | awk -F ' ' '{print $2}' | awk '{if(NR>1)print}')
ROUTE=$(echo ${ROUTE#*.})

oc replace --force -f - -n webapp <<EOF
apiVersion: "integreatly.org/v1alpha1"
kind: "WebApp"
metadata:
  name: tutorial-web-app
  namespace: webapp
  labels:
    app: tutorial-web-app
spec:
  app_label: tutorial-web-app
  template:
    path: /home/tutorial-web-app-operator/deploy/template/tutorial-web-app.yml
    parameters:
      OPENSHIFT_OAUTHCLIENT_ID: tutorial-web-app
      OPENSHIFT_OAUTH_HOST: "oauth-openshift.$ROUTE"
      OPENSHIFT_HOST: "console-openshift-console.$ROUTE"
      INSTALLED_SERVICES: |-
        { 
          "3scale":{ 
              "Host":"https://3scale-admin.$ROUTE",
              "Version":"2.7.0.GA"
          },
          "codeready":{ 
              "Host":"http://che-che.$ROUTE",
              "Version":"2.0.0"
          }
        }
      OPENSHIFT_VERSION: "4"
      WALKTHROUGH_LOCATIONS: https://github.com/hodrigohamalho/dayinthelife-streaming.git?walkthroughsFolder=/docs/labs/
EOF


# for i in $(seq 1 $NUM_USERS);
# do 
#     PROJECT=fuse-user$i
#     oc project $PROJECT

#     oc new-app --template=postgresql-persistent --param=POSTGRESQL_PASSWORD=redhat --param=POSTGRESQL_USER=redhat --param=POSTGRESQL_DATABASE=sampledb -n $PROJECT;
# done


# # Wait 1 minute until all pods are up and running
# echo "Let's wait a minute to all pods be available"
# sleep 60;

# # POPULATE THE DATABASE
# for i in $(seq 1 $NUM_USERS);
# do 
#     oc project fuse-user$i

#     POD_POSTGRESQL=$(oc get po | grep postgresql | grep -v deploy | awk '{print $1}')
#     oc exec -it $POD_POSTGRESQL -- bash -c 'psql -U redhat -d sampledb -c "CREATE TABLE users(id serial PRIMARY KEY,name VARCHAR (50),phone VARCHAR (50),age integer);"'
#     oc exec -it $POD_POSTGRESQL -- bash -c 'psql -U redhat -d sampledb -c "CREATE TABLE orders(id serial PRIMARY KEY, user_id INT, name VARCHAR (50),price decimal(12,2), CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id));"'

#     oc exec -it $POD_POSTGRESQL -- bash -c "psql -U redhat -d sampledb -c \"INSERT INTO users(name, phone, age) VALUES  ('Rodrigo Ramalho', '(11) 95474-8099', 30);INSERT INTO users(name, phone, age) VALUES  ('Thiago Araki', '(11) 95474-8099', 31);INSERT INTO users(name, phone, age) VALUES  ('Gustavo Luszczynski', '(61) 95474-8099', 29);INSERT INTO users(name, phone, age) VALUES  ('Rafael Tuelho', '(11) 95474-8099', 55);INSERT INTO users(name, phone, age) VALUES  ('Elvis', '(61) 95474-8099', 36);\""

#     oc exec -it $POD_POSTGRESQL -- bash -c "psql -U redhat -d sampledb -c \"INSERT INTO orders(name, price, user_id) VALUES  ('Fedora Hat', '10', 1);INSERT INTO orders(name, price, user_id) VALUES  ('RHEL', '15', 1);INSERT INTO orders(name, price, user_id) VALUES  ('3Scale', '5', 1);INSERT INTO orders(name, price, user_id) VALUES  ('Fuse', '25', 1);INSERT INTO orders(name, price, user_id) VALUES  ('AMQ', '25', 1);INSERT INTO orders(name, price, user_id) VALUES  ('DATAGRID', '35', 1);INSERT INTO orders(name, price, user_id) VALUES  ('Fedora Hat', '10', 2);INSERT INTO orders(name, price, user_id) VALUES  ('RHEL', '15', 2);INSERT INTO orders(name, price, user_id) VALUES  ('RHEL', '15', 3);\""
# done


# PROVISIONING 3Scale
echo "Strating 3scale provisioning..."
oc new-project $THREESCALE_PROJECT

oc create -f 3scale-storage.yaml -n $THREESCALE_PROJECT
oc create -f system-seed.yaml -n $THREESCALE_PROJECT

oc create -f - -n $THREESCALE_PROJECT <<EOF
apiVersion: apps.3scale.net/v1alpha1
kind: APIManager
metadata:
  name: 3scale
spec:
  wildcardDomain: $ROUTE
  resourceRequirementsEnabled: false
EOF

echo "After the 3scale correctly get up, run the install-tenants.sh. Make sure to fill the toke variable properly"

