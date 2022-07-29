# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Установка provisioner nfs:

```
➜  ~ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11156  100 11156    0     0  21681      0 --:--:-- --:--:-- --:--:-- 21662
Downloading https://get.helm.sh/helm-v3.9.2-darwin-arm64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
Password:
helm installed into /usr/local/bin/helm

➜  ~ helm repo add stable https://charts.helm.sh/stable && helm repo update
"stable" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kube" chart repository
...Successfully got an update from the "chartmuseum" chart repository
...Successfully got an update from the "elastic" chart repository
...Successfully got an update from the "mysqlha" chart repository
...Successfully got an update from the "bitnami" chart repository
...Successfully got an update from the "minio" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "prometheus" chart repository
Update Complete. ⎈Happy Helming!⎈

➜  ~ helm install nfs-server stable/nfs-server-provisioner
WARNING: This chart is deprecated
NAME: nfs-server
LAST DEPLOYED: Fri Jul 29 10:40:35 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi

✗ kubectl get po
NAME                                  READY   STATUS    RESTARTS   AGE
nfs-server-nfs-server-provisioner-0   1/1     Running   0          5m59s

✗ kubectl get svc
NAME                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                                                                     AGE
kubernetes                          ClusterIP   10.96.0.1      <none>        443/TCP                                                                                                     3d14h
nfs-server-nfs-server-provisioner   ClusterIP   10.100.33.79   <none>        2049/TCP,2049/UDP,32803/TCP,32803/UDP,20048/TCP,20048/UDP,875/TCP,875/UDP,111/TCP,111/UDP,662/TCP,662/UDP   6m12s
```


## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.


## Ответ:

Запустил контейнер из файла [20-stage-pod.yaml]()
```
✗ kubectl apply -f 20-stage-pod.yaml
pod/pod-int-volumes created

✗ kubectl get po,pvc,pv
NAME                                      READY   STATUS    RESTARTS   AGE
pod/nfs-server-nfs-server-provisioner-0   1/1     Running   0          9m6s
pod/pod-int-volumes                       2/2     Running   0          100s

NAME                                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/postgredb-postgres-0             Bound    pvc-955138b4-b490-4e96-9887-b2e66cdae004   1Gi        RWX            standard       10h
persistentvolumeclaim/postgres-db-disk-postgres-db-0   Bound    pvc-179d73b1-be6f-48cd-83ad-95dc8e45c75a   1Gi        RWX            standard       10h

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                    STORAGECLASS   REASON   AGE
persistentvolume/pvc-179d73b1-be6f-48cd-83ad-95dc8e45c75a   1Gi        RWX            Delete           Bound    default/postgres-db-disk-postgres-db-0   standard                10h
persistentvolume/pvc-955138b4-b490-4e96-9887-b2e66cdae004   1Gi        RWX            Delete           Bound    default/postgredb-postgres-0             standard                10h
```

Записываем в контейнер с `busybox`
```
✗ kubectl exec pod-int-volumes -c busybox -- sh -c 'echo "Hello nfs" > /tmp/cache/nfs.txt'

✗ kubectl exec -ti -c busybox pod-int-volumes -- ls -la /tmp/cache
total 12
drwxrwxrwx    2 root     root          4096 Jul 29 07:51 .
drwxrwxrwt    1 root     root          4096 Jul 29 07:53 ..
-rw-r--r--    1 root     root            10 Jul 29 07:51 nfs.txt

✗ kubectl exec -ti -c busybox pod-int-volumes -- cat /tmp/cache/nfs.txt
Hello nfs
```

Прочитываем из контейнера с `nginx`
```
✗ kubectl exec pod-int-volumes -c nginx -- ls -la /static
total 12
drwxrwxrwx 2 root root 4096 Jul 29 07:51 .
drwxr-xr-x 1 root root 4096 Jul 29 07:49 ..
-rw-r--r-- 1 root root   10 Jul 29 07:51 nfs.txt

✗ kubectl exec pod-int-volumes -c nginx -- sh -c 'cat /static/nfs.txt'
Hello nfs
```


## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.


# Ответ:

1. Создал PVC из файла - [10-pvc-nfs.yaml]()
```
✗ kubectl apply -f 10-pvc-nfs.yaml
persistentvolumeclaim/shared created

✗ kubectl get pvc
NAME                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
shared                           Bound    pvc-0b2181b0-6e1a-4efe-a5d3-7c48980270f3   1Gi        RWX            nfs            12s


```