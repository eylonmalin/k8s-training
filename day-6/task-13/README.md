# Task-12: Helm Chart from scratch

In this task we will install Lets-Chat-App using helm chart. (Lets-Chat-Web and Lets-Chat-DB will remain as before)

Installing helm : https://helm.sh/docs/intro/install/

1. First you should delete the lc-app  **deployment**, **service**
2. Create scaffold chart using **helm create lc-app**
3. Watch the files that has been created, what is the purpose of each file?
4. Delete the files that are not needed for this task : hpa.yaml, ingress.yaml, serviceaccount.yaml
5.Update the values.yaml with the image repository and tag of Lets-Chat-Web. The repository is eylonmalin/lets-chat-app and the tag is v1
6. Let's install the chart
  > * Install the helm chart using `helm install lc-app /path/to-chart`.
  > * What happened ? Was the pod created ? Why ?
  > * Run kubectl get deployment lc-app -oyaml.
  > * Why the deployment is not valid ?
  > * Change the values.yaml service account create to be false, and try again.
  > * What happen now ? Did the pod created ? Is it in healthy state ?
7. Now, lets add the missing configurations to the deployment.
  > * Add to values.yaml an env section:
  ```yaml
env: 
  MONGO_HOST:  lc-db
  MONGO_PORT: 27017
```
   > * Update the deployment.yaml to take the values from values.yaml. Example of using value in chart:
```yaml
          env:
        {{- range $name, $value := .Values.env }}
          - name: {{ $name }}
            value: {{ $value | quote }}
        {{- end }}
```
  > * Add to the deployment yaml env the values from the secrets:
```yaml
          - name: MONGO_USER
            valueFrom:
              secretKeyRef:
                name: lc-db
                key: username
          - name: MONGO_PASS
            valueFrom:
              secretKeyRef:
                name: lc-db
                key: password
  ```
  
  > * Update the deployment using `helm upgrade lc-app /path/to-chart`
  > * What is the pod status now ?
8. Unfortunately, the pod is in error state. We need to update the probe. Let's Update the probes to use http get with path: /login and port 8080
  >> * Add probe section to values.yaml with entry for path
  >> * Update the in values.yaml the service port to be 8080
  >> * Update the probes in the deployment.yaml to take the values from values.yaml
  >> * Upgrade the helm chart and watch the pod status
9. What about the service ? Is it working
10. Execute port-forward to lc-web service , and make sure the application is up and running.