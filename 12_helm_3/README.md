# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

## Ответ:

Использую конфигурацию подов из предыдущих работ

```
$kubectl -n production get all
NAME                                      READY   STATUS             RESTARTS   AGE
pod/nfs-server-nfs-server-provisioner-0   0/1     CrashLoopBackOff   457        5d18h
pod/prod-b-v2-69cbf87889-gsfb8            1/1     Running            1          5d19h
pod/prod-b-v2-69cbf87889-q29bx            1/1     Running            1          5d19h
pod/prod-f-v2-596886c7c-nm62r             1/1     Running            2          5d19h

NAME                                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                                                                     AGE
service/nfs-server-nfs-server-provisioner   ClusterIP   10.233.9.182   <none>        2049/TCP,2049/UDP,32803/TCP,32803/UDP,20048/TCP,20048/UDP,875/TCP,875/UDP,111/TCP,111/UDP,662/TCP,662/UDP   5d20h
service/prod-b-v2                           NodePort    10.233.59.30   <none>        8080:31667/TCP                                                                                              5d19h
service/prod-f-v2                           NodePort    10.233.4.114   <none>        8080:30799/TCP                                                                                              5d19h

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prod-b-v2   2/2     2            2           5d19h
deployment.apps/prod-f-v2   1/1     1            1           5d19h

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/prod-b-v2-69cbf87889   2         2         2       5d19h
replicaset.apps/prod-f-v2-596886c7c    1         1         1       5d19h

NAME                                                 READY   AGE
statefulset.apps/nfs-server-nfs-server-provisioner   0/1     5d20h
```


Выполняю проверку Фронта через Port-Forward <br>
Выполняю перенаправление перенаправление:

```
$ kubectl -n production port-forward deployment/prod-f-v2 :8080
Forwarding from 127.0.0.1:42439 -> 8080
Forwarding from [::1]:42439 -> 8080
Handling connection for 42439
Handling connection for 42439
```

Выполняю CURL:

```

```

## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.
