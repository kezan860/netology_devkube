# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

## Ответ:

1. Использую конфигурацию подов из предыдущих работ

```
$ kubectl -n prod get all
NAME                                      READY   STATUS    RESTARTS   AGE
pod/nfs-server-nfs-server-provisioner-0   1/1     Running   0          8m13s
pod/prod-b-v2-69cbf87889-klphc            1/1     Running   0          6m5s
pod/prod-b-v2-69cbf87889-qk4zk            1/1     Running   0          6m5s
pod/prod-f-v2-596886c7c-6pj4v             1/1     Running   0          6m5s

NAME                                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                                                     AGE
service/nfs-server-nfs-server-provisioner   ClusterIP   10.222.29.206   <none>        2049/TCP,2049/UDP,32803/TCP,32803/UDP,20048/TCP,20048/UDP,875/TCP,875/UDP,111/TCP,111/UDP,662/TCP,662/UDP   8m13s
service/prod-b-v2                           NodePort    10.222.27.192   <none>        8080:32026/TCP                                                                                              6m5s
service/prod-f-v2                           NodePort    10.222.92.67    <none>        8080:30919/TCP                                                                                              6m5s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prod-b-v2   2/2     2            2           6m5s
deployment.apps/prod-f-v2   1/1     1            1           6m5s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/prod-b-v2-69cbf87889   2         2         2       6m5s
replicaset.apps/prod-f-v2-596886c7c    1         1         1       6m5s

NAME                                                 READY   AGE
statefulset.apps/nfs-server-nfs-server-provisioner   1/1     8m13s
```

2. Выполняю проверку Фронта через Port-Forward
Выполняю перенаправление:

```
$ kubectl -n prod port-forward deployment/prod-f-v2 :8080
Forwarding from 127.0.0.1:11479 -> 8080
Forwarding from [::1]:11479 -> 8080
Handling connection for 11479

$ curl http://127.0.0.1

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

$ curl http://127.0.0.1:11479

<!doctype html><html lang="en"><head><meta charset="utf-8"/><link rel="shortcut icon" href="/favicon.ico"/><meta name="viewport" content="width=device-width,initial-scale=1"/><meta name="theme-color" content="#000000"/><link rel="manifest" href="/manifest.json"/><title>Product Inventory</title><link href="/static/css/main.a83f6bd7.chunk.css" rel="stylesheet"></head><body><noscript>You need to enable JavaScript to run this app.</noscript><div id="root"></div><script>!function(l){function e(e){for(var r,t,n=e[0],o=e[1],u=e[2],f=0,i=[];f<n.length;f++)t=n[f],p[t]&&i.push(p[t][0]),p[t]=0;for(r in o)Object.prototype.hasOwnProperty.call(o,r)&&(l[r]=o[r]);for(s&&s(e);i.length;)i.shift()();return c.push.apply(c,u||[]),a()}function a(){for(var e,r=0;r<c.length;r++){for(var t=c[r],n=!0,o=1;o<t.length;o++){var u=t[o];0!==p[u]&&(n=!1)}n&&(c.splice(r--,1),e=f(f.s=t[0]))}return e}var t={},p={1:0},c=[];function f(e){if(t[e])return t[e].exports;var r=t[e]={i:e,l:!1,exports:{}};return l[e].call(r.exports,r,r.exports,f),r.l=!0,r.exports}f.m=l,f.c=t,f.d=function(e,r,t){f.o(e,r)||Object.defineProperty(e,r,{enumerable:!0,get:t})},f.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},f.t=function(r,e){if(1&e&&(r=f(r)),8&e)return r;if(4&e&&"object"==typeof r&&r&&r.__esModule)return r;var t=Object.create(null);if(f.r(t),Object.defineProperty(t,"default",{enumerable:!0,value:r}),2&e&&"string"!=typeof r)for(var n in r)f.d(t,n,function(e){return r[e]}.bind(null,n));return t},f.n=function(e){var r=e&&e.__esModule?function(){return e.default}:function(){return e};return f.d(r,"a",r),r},f.o=function(e,r){return Object.prototype.hasOwnProperty.call(e,r)},f.p="/";var r=window.webpackJsonp=window.webpackJsonp||[],n=r.push.bind(r);r.push=e,r=r.slice();for(var o=0;o<r.length;o++)e(r[o]);var s=n;a()}([])</script><script src="/static/js/2.4c8ff4f9.chunk.js"></script><script src="/static/js/main.a9c590ed.chunk.js"></script></body></html>
```

3. Выполняю проверку Бэка

```
$ kubectl -n prod port-forward deployment/prod-b-v2 :8080
Forwarding from 127.0.0.1:46621 -> 8080
Forwarding from [::1]:46621 -> 8080

$ curl http://127.0.0.1

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>


$ curl http://127.0.0.1:46621

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>NotFoundError: Not Found<br> &nbsp; &nbsp;at /usr/src/app/app.js:22:8<br> &nbsp; &nbsp;at Layer.handle [as handle_request] (/usr/src/app/node_modules/express/lib/router/layer.js:95:5)<br> &nbsp; &nbsp;at trim_prefix (/usr/src/app/node_modules/express/lib/router/index.js:317:13)<br> &nbsp; &nbsp;at /usr/src/app/node_modules/express/lib/router/index.js:284:7<br> &nbsp; &nbsp;at Function.process_params (/usr/src/app/node_modules/express/lib/router/index.js:335:12)<br> &nbsp; &nbsp;at next (/usr/src/app/node_modules/express/lib/router/index.js:275:10)<br> &nbsp; &nbsp;at SendStream.error (/usr/src/app/node_modules/serve-static/index.js:121:7)<br> &nbsp; &nbsp;at SendStream.emit (events.js:198:13)<br> &nbsp; &nbsp;at SendStream.error (/usr/src/app/node_modules/send/index.js:270:17)<br> &nbsp; &nbsp;at SendStream.onStatError (/usr/src/app/node_modules/send/index.js:421:12)</pre>
</body>
</html>
```

## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.


```
$ kubectl -n prod get all
NAME                                      READY   STATUS    RESTARTS   AGE
pod/nfs-server-nfs-server-provisioner-0   1/1     Running   0          28m
pod/prod-b-v2-69cbf87889-klphc            1/1     Running   0          26m
pod/prod-b-v2-69cbf87889-qk4zk            1/1     Running   0          26m
pod/prod-f-v2-596886c7c-6pj4v             1/1     Running   0          26m

NAME                                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                                                     AGE
service/nfs-server-nfs-server-provisioner   ClusterIP   10.222.29.206   <none>        2049/TCP,2049/UDP,32803/TCP,32803/UDP,20048/TCP,20048/UDP,875/TCP,875/UDP,111/TCP,111/UDP,662/TCP,662/UDP   28m
service/prod-b-v2                           NodePort    10.222.27.192   <none>        8080:32026/TCP                                                                                              26m
service/prod-f-v2                           NodePort    10.222.92.67    <none>        8080:30919/TCP                                                                                              26m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prod-b-v2   2/2     2            2           26m
deployment.apps/prod-f-v2   1/1     1            1           26m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/prod-b-v2-69cbf87889   2         2         2       26m
replicaset.apps/prod-f-v2-596886c7c    1         1         1       26m

NAME                                                 READY   AGE
statefulset.apps/nfs-server-nfs-server-provisioner   1/1     28m
```

Масштабирование до 3х:

```
$ kubectl -n prod scale --replicas=3 deployment/prod-b-v2
deployment.apps/prod-b-v2 scaled

$ kubectl -n prod scale --replicas=3 deployment/prod-f-v2
deployment.apps/prod-f-v2 scaled

$ kubectl -n prod get po
NAME                                  READY   STATUS    RESTARTS   AGE
nfs-server-nfs-server-provisioner-0   1/1     Running   0          30m
prod-b-v2-69cbf87889-6sft6            1/1     Running   0          34s
prod-b-v2-69cbf87889-klphc            1/1     Running   0          28m
prod-b-v2-69cbf87889-qk4zk            1/1     Running   0          28m
prod-f-v2-596886c7c-2hwrw             1/1     Running   0          20s
prod-f-v2-596886c7c-6pj4v             1/1     Running   0          28m
prod-f-v2-596886c7c-ghwsd             1/1     Running   0          20s

$ kubectl -n prod  describe deployment/prod-b-v2
Name:                   prod-b-v2
Namespace:              prod
CreationTimestamp:      Fri, 29 Jul 2022 09:51:58 +0000
Labels:                 app=ecommerce
                        tier=back-v2
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=ecommerce,tier=back-v2
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=ecommerce
           tier=back-v2
  Containers:
   prod-b-v2:
    Image:      chrischinchilla/humanitech-product-be
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      DATABASE_HOST:      postgres
      DATABASE_NAME:      product
      DATABASE_PASSWORD:  pr0dr0b0t
      DATABASE_USER:      product_robot
      DATABASE_PORT:      5432
    Mounts:
      /mnt/nfs from data (rw)
  Volumes:
   data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  shared
    ReadOnly:   false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   prod-b-v2-69cbf87889 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled up replica set prod-b-v2-69cbf87889 to 2
  Normal  ScalingReplicaSet  60s   deployment-controller  Scaled up replica set prod-b-v2-69cbf87889 to 3

$ kubectl -n prod  describe deployment/prod-f-v2
Name:                   prod-f-v2
Namespace:              prod
CreationTimestamp:      Fri, 29 Jul 2022 09:51:58 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=ecommerce,tier=front-v2
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=ecommerce
           tier=front-v2
  Containers:
   client:
    Image:      chrischinchilla/humanitech-product-fe
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      PROD_B_V2_SERVER_URL:  prod-b-v2
    Mounts:
      /mnt/nfs from data (rw)
  Volumes:
   data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  shared
    ReadOnly:   false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   prod-f-v2-596886c7c (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  29m   deployment-controller  Scaled up replica set prod-f-v2-596886c7c to 1
  Normal  ScalingR
```
