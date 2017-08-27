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

{% if sqldeveloper.user != 'undefined_user' %}

sqldeveloper-product-conf-dir:
  file.directory:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper/{{ release }}
    - makedirs: True
    - require_in:
      - file: sqldeveloper-product-conf

sqldeveloper-product-conf:
  file.managed:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper/{{ release }}/product.conf
    - contents:
      - SetJavaHome /usr/lib/java

  {% if sqldeveloper.connections_url != 'undefined' %}
sqldeveloper-connections-xml:
  cmd.run:
    - name: curl -s -o /home/{{ sqldeveloper.user }}/.sqldeveloper/connections.xml '{{ sqldeveloper.connections_url }}'
    - if_missing: /home/{{ sqldeveloper.user }}/.sqldeveloper/connections.xml
    - runas: root
    - require:
      - sqldeveloper-product-conf-dir
    - require_in:
      - sqldeveloper-user-permissions
  {% endif %}

  {% if sqldeveloper.prefs_url != 'undefined' %}
sqldeveloper-get-preferences-importfile-from-url:
  cmd.run:
    - name: curl -s -o /home/{{ sqldeveloper.user }}/.sqldeveloper/my-preferences.xml '{{ sqldeveloper.prefs_url }}'
    - runas: {{ sqldeveloper.user }}
    - if_missing: /home/{{ sqldeveloper.user }}/my-preferences.xml
    - require:
      - sqldeveloper-product-conf-dir
    - require_in:
      - sqldeveloper-user-permissions
  {% elif sqldeveloper.prefs_path != 'undefined' %}
sqldeveloper-get-preferences-importfile-from-path:
  file.managed:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper/my-preferences.xml
    - source: {{ sqldeveloper.prefs_path }}
    - if_missing: /home/{{ sqldeveloper.user }}/.sqldeveloper/my-preferences.xml
    - require:
      - sqldeveloper-product-conf-dir
    - require_in:
      - sqldeveloper-user-permissions
  {% endif %}

sqldeveloper-user-permissions:
  file.directory:
    - name: /home/{{ sqldeveloper.user }}/.sqldeveloper 
    - mode:  744
    - user: {{ sqldeveloper.user }}
  {% if salt['grains.get']('os_family') == 'Suse' or salt['grains.get']('os') == 'SUSE' %}
    - group: users
  {% else %}
    - group: {{ sqldeveloper.user }}
  {% endif %}
    - recurse:
      - user
      - group
      - mode
    - onchanges:
      - sqldeveloper-product-conf-dir

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

