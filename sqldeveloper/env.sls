{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

{%- set release = sqldeveloper.version + '.' + sqldeveloper.major + '.' + sqldeveloper.minor %}

sqldeveloper-config:
  file.managed:
    - name: /etc/profile.d/sqldeveloper.sh
    - source: salt://sqldeveloper/files/sqldeveloper.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      orahome: {{ sqldeveloper.orahome }}/sqldeveloper

sqldeveloper-connections-dir:
  file.directory:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper/
    - backupname: /home/{{ pillar['user'] }}/.sqldeveloper_bak

{% if sqldeveloper.connections_url != 'undefined' %}
sqldeveloper-connections-xml:
  cmd.run:
    - name: curl -o /home/{{ pillar['user'] }}/.sqldeveloper/connections.xml '{{ sqldeveloper.connections_url }}'
    - if_missing: /home/{{ pillar['user'] }}/.sqldeveloper/connections.xml
    - require:
      - file: sqldeveloper-connections-dir
{% endif %}

sqldeveloper-product.conf:
  file.managed:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper/{{ release }}/product.conf
    - makedirs: True
    - require:
      - file: sqldeveloper-connections-dir

sqldeveloper-connections-permissions:
  file.recurse:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper
    - user: {{ pillar['user'] }}
  {% if salt['grains.get']('os_family') == 'Suse' or salt['grains.get']('os') == 'SUSE' %}
    - group: users
  {% else %}
    - group: {{ pillar['user'] }}
  {% endif %}
    - onchanges:
      - sqldeveloper-connections-dir
      - sqldeveloper-connections-xml
      - sqldeveloper-product.conf
    - require:
      - file: sqldeveloper-connections-dir

sqldeveloper-product.conf_append:
  file.append:
    - name: /home/{{ pillar['user'] }}/.sqldeveloper/{{ release }}/product.conf
    - text: 'SetJavaHome /usr/lib/java'
    - onchanges:
      - sqldeveloper-product.conf

# Add sqldeveloper home to alternatives system
sqldeveloperhome-alt-install:
  alternatives.install:
    - name: sqldeveloper-home
    - link: {{ sqldeveloper.orahome }}/sqldeveloper
    - path: {{ sqldeveloper.sqldeveloper_real_home }}
    - priority: {{ sqldeveloper.alt_priority }}

# Set sqldeveloper alternatives
sqldeveloperhome-alt-set:
  alternatives.set:
    - name: sqldeveloper-home
    - path: {{ sqldeveloper.sqldeveloper_real_home }}
    - onchanges:
      - alternatives: sqldeveloperhome-alt-install

# Add sqldeveloper to alternatives system
sqldeveloper-alt-install:
  alternatives.install:
    - name: sqldeveloper
    - link: {{ sqldeveloper.sqldeveloper_symlink }}
    - path: {{ sqldeveloper.sqldeveloper_realcmd }}
    - priority: {{ sqldeveloper.alt_priority }}
    - onchanges:
      - alternatives: sqldeveloperhome-alt-set

sqldeveloper-alt-set:
  alternatives.set:
    - name: sqldeveloper
    - path: {{ sqldeveloper.sqldeveloper_realcmd }}
    - onchanges:
      - alternatives: sqldeveloper-alt-install

