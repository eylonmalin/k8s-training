# Task-12: Write Helm Chart for Lets-Chat-Web

In this task we will install Lets-Chat-Web using helm chart.
The Lets-Chat-Web will be a deployment, service and config map.
We are going to rewrite the existing yaml files to helm chart.  


Installing helm : https://helm.sh/docs/intro/install/

1. First you should delete the Lets-Chat-Web **deployment**, **service**  and **configmap**.
2. Checkout the lc-web dir. 
3. Fill the values.yaml with the image tag of Lets-Chat-Web. Take the image from the deployment.yaml.
4. Change the deployment.yaml to take the values from values.yaml. Example of using value in chart: 
```yaml
        image: {{ .Values.image.tag }}
```
5. Run `helm install --dry-run lc-web /path-of/chart-path`, where /path-of/chart-path is the path to the created charts directory. Review the yamls that are generated.
6. If you are satisfied with the result, install the chart with `helm install lc-web /path-of/chart-path`
7. Watch the created helm by using 'helm list'
8. Use kubectl to get the created resources - deployment, pod, config-map, service
9. Upgrade the image tag to version v2, and use `helm upgrade lc-web /path-of/chart-path` for upgrading the chart.
10. Use `kubectl get deploy lc-web -oyaml` and kubectl logs to make sure the deployment was upgraded.
11. Use `helm rollback lc-web` for rollback the upgrade. Use kubectl to make sure the rollback was success.
12. Use values for app configuration
  > * Add values for app host, and app port, and change the deployment.yaml to use the values from values.yaml.
  > * Use helm upgrade for applying these changes.
  > * Run port-forward and make sure the application is still up and running.


 
