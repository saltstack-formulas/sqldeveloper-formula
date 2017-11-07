{% from "sqldeveloper/map.jinja" import sqldeveloper with context %}

{% if sqldeveloper.prefs.user not in (None, 'undefined', 'undefined_user', '',) %}

  {% if grains.os == 'MacOS' %}
sqldeveloper-desktop-shortcut-clean:
  file.absent:
    - name: '{{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/Desktop/SqlDeveloper'
    - require_in:
      - file: sqldeveloper-desktop-shortcut-add
  {% endif %}

sqldeveloper-desktop-shortcut-add:
  {% if grains.os == 'MacOS' %}
  file.managed:
    - name: /tmp/mac_shortcut.sh
    - source: salt://sqldeveloper/files/mac_shortcut.sh
    - mode: 755
    - template: jinja
    - context:
      user: {{ sqldeveloper.prefs.user }}
      homes: {{ sqldeveloper.homes }}
  cmd.run:
    - name: /tmp/mac_shortcut.sh
    - runas: {{ sqldeveloper.prefs.user }}
    - require:
      - file: sqldeveloper-desktop-shortcut-add
  {% elif grains.os not in ('Windows',) %}
  #Linux
  file.managed:
    - source: salt://sqldeveloper/files/sqldeveloper.desktop
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/Desktop/sqldeveloper.desktop
    - user: {{ sqldeveloper.prefs.user }}
    - makedirs: True
      {% if grains.os_family in ('Suse',) %} 
    - group: users
      {% else %}
    - group: {{ sqldeveloper.prefs.user }}
      {% endif %}
    - mode: 644
    - force: True
    - template: jinja
      #On Suse realcmd cannot be resolved??
    - onlyif: test -d {{ sqldeveloper.oracle.realhome }}
    - context:
      home: {{ sqldeveloper.oracle.home }}
      command: {{ sqldeveloper.command }}

sqldeveloper-product-conf-dir:
  file.directory:
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/.sqldeveloper/{{ sqldeveloper.oracle.release }}
    - makedirs: True
    - require_in:
      - file: sqldeveloper-product-conf

sqldeveloper-product-conf:
  file.managed:
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/.sqldeveloper/{{ sqldeveloper.oracle.release }}/product.conf
    - contents:
      - SetJavaHome /usr/lib/java

sqldeveloper-product-conf-permissions:
  file.directory:
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/.sqldeveloper
    - mode:  744
    - user: {{ sqldeveloper.prefs.user }}
    {% if grains.os_family in ('Suse',) or grains.os in ('SUSE',) %}
    - group: users
    {% else %}
    - group: {{ sqldeveloper.prefs.user }}
    {% endif %}
    - recurse:
      - user
      - group
      - mode
    - onchanges:
      - sqldeveloper-product-conf-dir

  {% endif %}


  {% if sqldeveloper.prefs.xmlurl or sqldeveloper.prefs.xmldir %}
    {% set connections_xml = sqldeveloper.homes ~ '/' ~ sqldeveloper.prefs.user ~ '/' ~ sqldeveloper.prefs.xmlfile %}

sqldeveloper-prefs-xmlfile:
    {% if sqldeveloper.prefs.xmldir %}
  file.managed:
    - onlyif: test -f {{ sqldeveloper.prefs.xmldir }}/{{ sqldeveloper.prefs.xmlfile }}
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/{{ sqldeveloper.prefs.xmlfile }}
    - source: {{ sqldeveloper.prefs.xmldir }}/{{ sqldeveloper.prefs.xmlfile }}
    - user: {{ sqldeveloper.prefs.user }}
    - makedirs: True
        {% if grains.os_family in ('Suse',) %}
    - group: users
        {% elif grains.os not in ('MacOS',) %}
        #inherit Darwin ownership
    - group: {{ sqldeveloper.prefs.user }}
        {% endif %}
    - if_missing: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/{{ sqldeveloper.prefs.xmlfile }}
    {% else %}
  cmd.run:
    - name: curl -o {{ connections_xml }} {{sqldeveloper.prefs.xmlurl}}
    - runas: {{ sqldeveloper.prefs.user }}
    - if_missing: {{ connections_xml }}
    {% endif %}

  {% endif %}

{% endif %}

