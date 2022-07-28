# Домашнее задание к занятию "11.04 Микросервисы: масштабирование"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: Кластеризация

Предложите решение для обеспечения развертывания, запуска и управления приложениями.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- Поддержка контейнеров;
- Обеспечивать обнаружение сервисов и маршрутизацию запросов;
- Обеспечивать возможность горизонтального масштабирования;
- Обеспечивать возможность автоматического масштабирования;
- Обеспечивать явное разделение ресурсов доступных извне и внутри системы;
- Обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т.п.

Обоснуйте свой выбор.

## Ответ:

при вополнении дополнительно использовал данные из [статьи](https://mcs.mail.ru/blog/sravnenie-kubernetes-s-drugimi-resheniyami).


| Критерий\Инструмент | Kubernetes | Docker Swarm | Nomand | Apache Mesos (+Marathon, Aurora) |
| ------------------- | ---------- | ------------ | ------ | -------------------------------- |
| Поддержка контейнеров | + | + | + | + |
| Обнаружение сервисов и маршрутизацию запросов | + | + | - | + |
| Возможность горизонтального масштабирования | + | + | + | + |
| Возможность автоматического масштабирования | + | - | + | + |
| Явное разделения ресурсов доступных извне и внутри системы | + | - | + | + |
| Возможность конфигурирования приложения с помощью переменных среды, в т.ч. безопасное хранение чувствительных данных (пароли, ключи) | + | + | + | + |

Рассмотренные решения в осоновном схожи. 
Выбор итогового решения зависит от условий, в рамках которых будет использоваться конечная система.

Кроме всего прочего для крупной компании я бы так же опирался на наличии дополнительных функций 
безопастности использования, популярность инструмента т.к. полпулярный сервис активно развивается, 
все ошибки оперативно исправляются и система являетсяболее тсбильнойиваться.

В итоге, на мой взгляд, правильным решением было бы остановиться на k8s (в нашей компании именно такое решение и было принято)