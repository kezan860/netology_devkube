# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

## Ответ:

```
kubectl create deployment hello-node --image=kezan86/myhello --replicas=2
deployment.apps/hello-node created

kubectl get deploy
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           36s

kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-64df8db489-gdn58   1/1     Running   0          51s
hello-node-64df8db489-psjl7   1/1     Running   0          51s
```


## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

## Ответ:

Конфиг пользователя:
```kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://kubernetes.docker.internal:6443
  name: docker-desktop
- cluster:
    certificate-authority: /Users/vlad/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Tue, 26 Jul 2022 15:01:17 MSK
        provider: minikube.sigs.k8s.io
        version: v1.26.0
      name: cluster_info
    server: https://127.0.0.1:59274
  name: minikube
contexts:
- context:
    cluster: docker-desktop
    user: docker-desktop
  name: docker-desktop
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Tue, 26 Jul 2022 15:01:17 MSK
        provider: minikube.sigs.k8s.io
        version: v1.26.0
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: docker-desktop
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: minikube
  user:
    client-certificate: /Users/vlad/.minikube/profiles/minikube/client.crt
    client-key: /Users/vlad/.minikube/profiles/minikube/client.key
```

Вывод логов приложения:
```
kubectl logs -l app=hello-node
Running demo app. Press Ctrl+C to exit...
Running demo app. Press Ctrl+C to exit...
```

Детальная инфомрация по деплою:
```
kubectl describe deploy hello-node
Name:                   hello-node
Namespace:              default
CreationTimestamp:      Tue, 26 Jul 2022 15:47:43 +0300
Labels:                 app=hello-node
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=hello-node
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=hello-node
  Containers:
   myhello:
    Image:        kezan86/myhello
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   hello-node-64df8db489 (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  6m54s  deployment-controller  Scaled up replica set hello-node-64df8db489 to 2
```

Детальная инфомрация по поду:
```
kubectl describe po hello-node-64df8db489-gdn58
Name:         hello-node-64df8db489-gdn58
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Tue, 26 Jul 2022 15:47:43 +0300
Labels:       app=hello-node
              pod-template-hash=64df8db489
Annotations:  <none>
Status:       Running
IP:           172.17.0.6
IPs:
  IP:           172.17.0.6
Controlled By:  ReplicaSet/hello-node-64df8db489
Containers:
  myhello:
    Container ID:   docker://6af1ac55d4447a363f425910acae7383835362973222c96965bffa44349a8122
    Image:          kezan86/myhello
    Image ID:       docker-pullable://kezan86/myhello@sha256:129e13233adb8444c7cf0d5f55ad6c65a9ff9a5081e31d58084564b61459aa3d
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 26 Jul 2022 15:47:47 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mn7vr (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-mn7vr:
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
  Normal  Scheduled  7m46s  default-scheduler  Successfully assigned default/hello-node-64df8db489-gdn58 to minikube
  Normal  Pulling    7m46s  kubelet            Pulling image "kezan86/myhello"
  Normal  Pulled     7m43s  kubelet            Successfully pulled image "kezan86/myhello" in 2.952335959s
  Normal  Created    7m43s  kubelet            Created container myhello
  Normal  Started    7m43s  kubelet            Started container myhello
```

## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

Поскейлил количесвто подов до 5-ти:
```
kubectl scale deploy hello-node --replicas=5
deployment.apps/hello-node scaled

kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-64df8db489-gdn58   1/1     Running   0          9m55s
hello-node-64df8db489-jjgxh   1/1     Running   0          29s
hello-node-64df8db489-psjl7   1/1     Running   0          9m55s
hello-node-64df8db489-w6kvb   1/1     Running   0          29s
hello-node-64df8db489-xcwd4   1/1     Running   0          29s
```
