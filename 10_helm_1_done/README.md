# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

## Ответ:

Подготовил два файла:

1) Для запуска фронтенда и бекенда в stage окружении - [10-app.yaml](https://github.com/kezan860/netology_devkube/blob/master/10_helm_1/.helm/stage/10-app.yaml)
2) Для запуска базы данных в stage окружении - [20-postgres.yaml](https://github.com/kezan860/netology_devkube/blob/master/10_helm_1/.helm/stage/20-postgres.yaml)

Ход выполения:
```
✗ kubectl apply -f 10-app.yaml
deployment.apps/fb-pod created
service/fb-svc created

✗ kubectl apply -f 20-postgres.yaml
statefulset.apps/postgres-db created
service/postgres-db-lb created
persistentvolume/nfs-pv created

✗ kubectl get svc
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
fb-svc           NodePort       10.106.26.73    <none>        80:30080/TCP     2m47s
kubernetes       ClusterIP      10.96.0.1       <none>        443/TCP          3d4h
postgres-db-lb   LoadBalancer   10.103.59.137   <pending>     5432:30743/TCP   2m11s

✗ kubectl get po
NAME                     READY   STATUS    RESTARTS   AGE
fb-pod-584f4fb74-wp4kt   2/2     Running   0          3m15s
postgres-db-0            1/1     Running   0          2m39s

✗ kubectl describe po fb-pod-584f4fb74-wp4kt
Name:         fb-pod-584f4fb74-wp4kt
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Fri, 29 Jul 2022 00:03:12 +0300
Labels:       app=fb-app
              pod-template-hash=584f4fb74
Annotations:  <none>
Status:       Running
IP:           172.17.0.11
IPs:
  IP:           172.17.0.11
Controlled By:  ReplicaSet/fb-pod-584f4fb74
Containers:
  front:
    Container ID:   docker://d607875096fbe6a114f4f8ef0b8f83df7ffae34583211817d1e7cd0c28c3b3e5
    Image:          nginx:1.14.2
    Image ID:       docker-pullable://nginx@sha256:f7988fb6c02e0ce69257d9bd9cf37ae20a60f1df7563c3a2a6abe24160306b8d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Fri, 29 Jul 2022 00:03:42 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hrf9m (ro)
  back:
    Container ID:  docker://c43e8c2dab85c0d967934448e394e1406f71bf799e6c8132f4eeb227aead60db
    Image:         debian
    Image ID:      docker-pullable://debian@sha256:2ce44bbc00a79113c296d9d25524e15d423b23303fdbbe20190d2f96e0aeb251
    Port:          <none>
    Host Port:     <none>
    Command:
      sleep
      3600
    State:          Running
      Started:      Fri, 29 Jul 2022 00:04:18 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hrf9m (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-hrf9m:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m58s  default-scheduler  Successfully assigned default/fb-pod-584f4fb74-wp4kt to minikube
  Normal  Pulling    3m58s  kubelet            Pulling image "nginx:1.14.2"
  Normal  Pulled     3m29s  kubelet            Successfully pulled image "nginx:1.14.2" in 29.285110263s
  Normal  Created    3m29s  kubelet            Created container front
  Normal  Started    3m29s  kubelet            Started container front
  Normal  Pulling    3m29s  kubelet            Pulling image "debian"
  Normal  Pulled     2m54s  kubelet            Successfully pulled image "debian" in 35.160798974s
  Normal  Created    2m53s  kubelet            Created container back
  Normal  Started    2m53s  kubelet            Started container back

✗ kubectl describe deploy fb-pod
Name:                   fb-pod
Namespace:              default
CreationTimestamp:      Fri, 29 Jul 2022 00:03:12 +0300
Labels:                 app=fb-app
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=fb-app
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=fb-app
  Containers:
   front:
    Image:        nginx:1.14.2
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   back:
    Image:      debian
    Port:       <none>
    Host Port:  <none>
    Command:
      sleep
      3600
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   fb-pod-584f4fb74 (1/1 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  4m32s  deployment-controller  Scaled up replica set fb-pod-584f4fb74 to 1

✗ kubectl get sts
NAME          READY   AGE
postgres-db   1/1     4m52s

✗ kubectl describe sts postgres-db
Name:               postgres-db
Namespace:          default
CreationTimestamp:  Fri, 29 Jul 2022 00:03:48 +0300
Selector:           app=postgres-db
Labels:             <none>
Annotations:        <none>
Replicas:           1 desired | 1 total
Update Strategy:    RollingUpdate
  Partition:        0
Pods Status:        1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=postgres-db
  Containers:
   postgres-sdb:
    Image:      postgres:latest
    Port:       <none>
    Host Port:  <none>
    Environment:
      POSTGRES_PASSWORD:  testpassword
      PGDATA:             /data/pgdata
    Mounts:
      /data from postgres-db-disk (rw)
  Volumes:  <none>
Volume Claims:
  Name:          postgres-db-disk
  StorageClass:
  Labels:        <none>
  Annotations:   <none>
  Capacity:      1Gi
  Access Modes:  [ReadWriteMany]
Events:
  Type    Reason            Age    From                    Message
  ----    ------            ----   ----                    -------
  Normal  SuccessfulCreate  4m20s  statefulset-controller  create Claim postgres-db-disk-postgres-db-0 Pod postgres-db-0 in StatefulSet postgres-db success
  Normal  SuccessfulCreate  4m20s  statefulset-controller  create Pod postgres-db-0 in StatefulSet postgres-db successful
```

## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

## Ответ:

Подготовил три файла:

1) Для запуска фронтенда в production окружении - [10-front.yaml](https://github.com/kezan860/netology_devkube/blob/master/10_helm_1/.helm/production/10-front.yaml)
2) Для запуска бекенда в production окружении - [20-back.yaml](https://github.com/kezan860/netology_devkube/blob/master/10_helm_1/.helm/production/20-back.yaml)
3) Для запуска базы данных в production окружении - [30-postgres.yaml](https://github.com/kezan860/netology_devkube/blob/master/10_helm_1/.helm/production/30-postgres.yaml)

Ход выполнения:

```
✗ kubectl apply -f 10-front.yaml -f 20-back.yaml -f 30-postgres.yaml
deployment.apps/prod-f created
service/produ-f created
deployment.apps/prod-b created
service/prod-b created
statefulset.apps/postgres created
configmap/postgres-config created
service/postgres created
persistentvolume/nfs-pv-prod created

✗ kubectl get po
NAME                      READY   STATUS    RESTARTS   AGE
postgres-0                1/1     Running   0          6m17s
prod-b-7965d8947-c9wf6    1/1     Running   0          84s
prod-b-7965d8947-zlrsc    1/1     Running   0          86s
prod-f-7c77bfcf4d-8xw6h   1/1     Running   0          2m45s

✗ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP          3d4h
postgres     NodePort    10.100.215.35   <none>        5432:31066/TCP   6m28s
prod-b       NodePort    10.98.196.33    <none>        8080:31462/TCP   6m28s
produ-f      NodePort    10.101.212.48   <none>        8080:31639/TCP   6m28s

✗ kubectl get deploy
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
prod-b   2/2     2            2           6m55s
prod-f   1/1     1            1           6m55s

✗ kubectl get sts
NAME       READY   AGE
postgres   1/1     7m4s

✗ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                    STORAGECLASS   REASON   AGE
nfs-pv-prod                                1Gi        RWX            Retain           Available                                                                    7m18s
pvc-179d73b1-be6f-48cd-83ad-95dc8e45c75a   1Gi        RWX            Delete           Bound       default/postgres-db-disk-postgres-db-0   standard                16m
pvc-955138b4-b490-4e96-9887-b2e66cdae004   1Gi        RWX            Delete           Bound       default/postgredb-postgres-0             standard                7m18s

✗ kubectl get pvc
NAME                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgredb-postgres-0             Bound    pvc-955138b4-b490-4e96-9887-b2e66cdae004   1Gi        RWX            standard       7m26s
postgres-db-disk-postgres-db-0   Bound    pvc-179d73b1-be6f-48cd-83ad-95dc8e45c75a   1Gi        RWX            standard       16m
```
