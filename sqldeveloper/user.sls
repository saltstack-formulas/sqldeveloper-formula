sqldeveloper-product.conf:
  file.managed:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper/4.0.0/product.conf
    - makedirs: True
    - user: {{ pillar['user'] }}
    - group: {{ pillar['user'] }}


# TODO: REVIEW

#sqldeveloper-product.conf_append:
#  file.append:
#    - name: /home/{{ pillar['user'] }}/.sqldeveloper/4.0.0/product.conf
#    - text: 'SetJavaHome /usr/lib/jvm/java-1.7.0-openjdk-amd64'

#sqldeveloper-connections.xml:
#  file.managed:
#    - name: /home/{{ pillar['user'] }}/.sqldeveloper/system4.0.2.15.21/o.jdeveloper.db.connection.12.1.3.2.41.140418.1111/connections.xml
#    - source: salt://sqldeveloper/connections.xml
#    - makedirs: True
#    - user: {{ pillar['user'] }}
#    - group: {{ pillar['user'] }}
