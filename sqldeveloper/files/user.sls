
##TODO: THINK THIS IS MOSTLY NOT NEEDED (USING LD_LIBRARY_PATH INSTEAD)
##Remove this file if states below are not needed. Maybe connections.xml might be useful todo.

sqldeveloper-product.conf:
  file.managed:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper/4.0.0/product.conf
    - makedirs: True
    - user: {{ pillar['user'] }}
{% if salt['grains.get']('os_family') == 'Suse' %}
    - group: users
{% else %}
    - group: {{ pillar['user'] }}
{% endif %}

sqldeveloper-product.conf_append:
  file.append:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper/4.0.0/product.conf
    - text: 'SetJavaHome /usr/lib/jvm/java-1.7.0-openjdk-amd64'

sqldeveloper-connections.xml:
  file.managed:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper/system4.0.2.15.21/o.jdeveloper.db.connection.12.1.3.2.41.140418.1111/connections.xml
    - source: salt://sqldeveloper/files/connections.xml
    - makedirs: True
    - user: {{ pillar['user'] }}
    - group: {{ pillar['user'] }}
