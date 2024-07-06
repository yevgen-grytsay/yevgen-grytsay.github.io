# Fluent-bit: `pods "X" not found`

**Tags:** fluent-bit, kubernetes, monitoring

Чомусь Fluent-bit неправильно визначав імена подів, через що не міг отримати інформацію про поди, щоб включити цю інформацію в лог.

У логах самого Fluent-bit (при `logLevel: debug`) з'являлись такі повідомлення:

```
[2024/06/10 22:12:08] [debug] [input:tail:tail.0] inode=1069058, /var/log/containers/eureka-server-d5c5776b6-dh5x2_default_eureka-server-092be7f49771b95692095c84771282b9f106bfa9f6ce03e5ebf8491dcc6d4aa2.log, events: IN_MODIFY
[2024/06/10 22:12:08] [debug] [filter:kubernetes:kubernetes.0] Send out request to API Server for pods information
[2024/06/10 22:12:08] [debug] [http_client] not using http_proxy for header
[2024/06/10 22:12:08] [debug] [http_client] server kubernetes.default.svc:443 will close connection #54
[2024/06/10 22:12:08] [debug] [filter:kubernetes:kubernetes.0] Request (ns=default, pod=s.eureka-server-d5c5776b6-dh5x2) http_do=0, HTTP Status: 404
[2024/06/10 22:12:08] [debug] [filter:kubernetes:kubernetes.0] HTTP response
{"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"pods \"s.eureka-server-d5c5776b6-dh5x2\" not found","reason":"NotFound","details":{"name":"s.eureka-server-d5c5776b6-dh5x2","kind":"pods"},"code":404}
```

Нас цікавить останнє повідомлення:

> {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"pods \"s.eureka-server-d5c5776b6-dh5x2\" not found","reason":"NotFound","details":{"name":"s.eureka-server-d5c5776b6-dh5x2","kind":"pods"},"code":404}

Пофіксилося явним вказанням потрібного парсера -- [kube-custom](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf#L127). Цей парсер вже включений до стандартної конфігурації Fluent-bit і виглядає таким чином:

```
[PARSER]
    Name    kube-custom
    Format  regex
    Regex   (?<tag>[^.]+)?\.?(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$
```

Повна конфігурація виглядає так:

```
[INPUT]
    Name tail
    Tag eureka.*
    Path /var/log/containers/eureka-client-*.log,/var/log/containers/eureka-server-*.log
    multiline.parser java
    Mem_Buf_Limit 5MB
    Skip_Long_Lines On

[FILTER]
    Name                kubernetes
    Match               eureka.*
    Kube_URL            https://kubernetes.default.svc:443
    Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
    Merge_Log           On
    Merge_Log_Key       original_log
    Keep_Log            Off
    Labels              On
    Annotations         On
    Regex_Parser        kube-custom


[OUTPUT]
    name loki
    host loki
    port 3100
    match eureka.*
    auto_kubernetes_labels on
```
