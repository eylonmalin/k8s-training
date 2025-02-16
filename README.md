# Using Kubernetes Training
In this course, you'll learn: 
- The origin, architecture, primary components, and building blocks of Kubernetes
- How to set up and access a Kubernetes cluster using Kind
- Ways to run applications on the deployed Kubernetes environment and access the deployed applications


## K8s Training with Lets-Chat
In this training we will deploy and scale **let's chat** application on kubernetes cluster. Let's Chat is a persistent messaging application that runs on Node.js and MongoDB with Nginx at the front.

![Let's Chat](http://i.imgur.com/0a3l5VF.png)

![Screenshot](http://i.imgur.com/C4uMD67.png)

### Let's Chat Architecture
![image](/assets/lets-chat-architecture.png)


### Tasks
1.  [Deploy and Explore Lets-Chat-Web](day-1/task-1/README.md)
2.  [Expose and Scale Lets-Chat-Web](day-1/task-2/README.md)
3.  [Rolling-Update Lets-Chat-Web](day-2/task-3/README.md)
4.  [Discover all Lets-Chat microservices](day-2/task-4/README.md)
5.  [Set Health-Checks and Self-Healing to Containers](day-3/task-5/README.md)
6.  [Get ENV Values from ConfigMap and Secrets](day-3/task-6/README.md)
7.  [Inject Files to Containers Using **configMap** and **secret** Volumes](day-4/task-7/README.md)
8.  [Share Directory Between 2 Containers in a Pod Using **emptyDir** Volume.](day-4/task-8/README.md)
9.  [Persist Lets-Chat-DB into the Node File-System Using **hostPath** Volume](day-5/task-9/README.md)
10. [Persist Lets-Chat-APP into External Shared File-System Using **persistentVolumeClaim** Volume](day-5/task-9-advanced/README.md)
11. [Expose Lets-Chat on FQDN:80 Using Ingress and Nginx-Controller](day-6/task-12/README-prev)
12. [Write Helm Chart for Lets-Chat-Web](day-6/task-12/README-prev)
13. [Use Lets-Chat chart-of-charts To Install/Upgrade](day-6/task-13/README.md)


### Installations
1. [Windows](installations/windows.md)
2. [Mac](installations/mac.md)
