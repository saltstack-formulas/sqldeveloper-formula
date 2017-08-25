{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

{%- set release = sqldeveloper.version ~ '.' ~ sqldeveloper.major ~ '.' ~ sqldeveloper.minor %}

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

{% if sqldeveloper.user != 'undefined' %}
sqldeveloper-connections-dir:
  file.directory:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper/
    - backupname: /home/{{ sqldeveloper.user }}/.bak

  {% if sqldeveloper.connections_url != 'undefined' %}
sqldeveloper-connections-xml:
  cmd.run:
    - name: curl -s -o /home/{{ sqldeveloper.user }}/.sqldeveloper/connections.xml '{{ sqldeveloper.connections_url }}'
    - if_missing: /home/{{ sqldeveloper.user }}/.sqldeveloper/connections.xml
    - require:
      - file: sqldeveloper-connections-dir
  {% endif %}

  {% if sqldeveloper.settings_url != 'undefined' %}
sqldeveloper-get-settings-importfile-from-url:
  cmd.run:
    - name: curl -s -o /home/{{ sqldeveloper.user }}/.sqldeveloper/my-connections-passwords.xml '{{ sqldeveloper.settings_url }}'
    - if_missing: /home/{{ sqldeveloper.user }}/my-connections-passwords.xml
  {% elif sqldeveloper.settings_path != 'undefined' %}
sqldeveloper-get-settings-importfile-from-path:
  file.managed:
    - name: /home/{{ sqldeveloper.user }}/my-connections-passwords.xml
    - source: {{ sqldeveloper.settings_path }}
    - mode: 644
    - user: {{ sqldeveloper.user }}
      {% if salt['grains.get']('os_family') == 'Suse' or salt['grains.get']('os') == 'SUSE' %}
    - group: users
      {% else %}
    - group: {{ sqldeveloper.user }}
      {% endif %}
    - if_missing: /home/{{ sqldeveloper.user }}/my-connections-passwords.xml
  {% endif %}
{% endif %}

sqldeveloper-product.conf:
  file.managed:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper/{{ release }}/product.conf
    - makedirs: True
    - require:
      - file: sqldeveloper-connections-dir

sqldeveloper-connections-permissions:
  file.recurse:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper
    - user: {{ sqldeveloper.user }}
  {% if salt['grains.get']('os_family') == 'Suse' or salt['grains.get']('os') == 'SUSE' %}
    - group: users
  {% else %}
    - group: {{ sqldeveloper.user }}
  {% endif %}
    - onchanges:
      - sqldeveloper-connections-dir
      - sqldeveloper-connections-xml
      - sqldeveloper-product.conf
    - require:
      - file: sqldeveloper-connections-dir

sqldeveloper-product.conf_append:
  file.append:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper/{{ release }}/product.conf
    - text: 'SetJavaHome /usr/lib/java'
    - onchanges:
      - sqldeveloper-product.conf
{% endif %}

# Add sqldeveloper home to alternatives system
sqldeveloperhome-alt-install:
  alternatives.install:
    - name: sqldeveloper-home
    - link: {{ sqldeveloper.orahome }}/sqldeveloper
    - path: {{ sqldeveloper.real_home }}
    - priority: {{ sqldeveloper.alt_priority }}

# Set sqldeveloper alternatives
sqldeveloperhome-alt-set:
  alternatives.set:
    - name: sqldeveloper-home
    - path: {{ sqldeveloper.real_home }}
    - onchanges:
      - alternatives: sqldeveloperhome-alt-install

# Add sqldeveloper to alternatives system
sqldeveloper-alt-install:
  alternatives.install:
    - name: sqldeveloper
    - link: {{ sqldeveloper.symlink }}
    - path: {{ sqldeveloper.realcmd }}
    - priority: {{ sqldeveloper.alt_priority }}
    - onchanges:
      - alternatives: sqldeveloperhome-alt-set

sqldeveloper-alt-set:
  alternatives.set:
    - name: sqldeveloper
    - path: {{ sqldeveloper.realcmd }}
    - onchanges:
      - alternatives: sqldeveloper-alt-install

