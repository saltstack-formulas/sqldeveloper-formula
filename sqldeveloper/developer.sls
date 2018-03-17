{% from "sqldeveloper/map.jinja" import sqldeveloper with context %}

  {% if grains.os == 'MacOS' %}
    {% set macgroup = salt['cmd.run']("stat -f '%Sg' /dev/console") %}
  {% endif %}

{% if sqldeveloper.prefs.user %}
   {% if grains.os != 'Windows' %}

sqldeveloper-desktop-shortcut-clean:
  file.absent:
    - name: '{{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/Desktop/SqlDeveloper'
    - require_in:
      - file: sqldeveloper-desktop-shortcut-add
    - onlyif: test "`uname`" = "Darwin"

sqldeveloper-desktop-shortcut-add:
  file.managed:
    - name: /tmp/mac_shortcut.sh
    - source: salt://sqldeveloper/files/mac_shortcut.sh
    - mode: 755
    - template: jinja
    - context:
      user: {{ sqldeveloper.prefs.user }}
      homes: {{ sqldeveloper.homes }}
    - onlyif: test "`uname`" = "Darwin"
  cmd.run:
    - name: /tmp/mac_shortcut.sh
    - runas: {{ sqldeveloper.prefs.user }}
    - require:
      - file: sqldeveloper-desktop-shortcut-add
    - require_in:
      - file: sqldeveloper-desktop-shortcut-install
    - onlyif: test "`uname`" = "Darwin"

sqldeveloper-desktop-shortcut-install:
  file.managed:
    - source: salt://sqldeveloper/files/sqldeveloper.desktop
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/Desktop/sqldeveloper.desktop
    - makedirs: True
    - user: {{ sqldeveloper.prefs.user }}
       {% if sqldeveloper.prefs.group and grains.os not in ('MacOS',) %}
    - group: {{ sqldeveloper.prefs.group }}
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
    - user: {{ sqldeveloper.prefs.user }}
       {% if sqldeveloper.prefs.group and grains.os not in ('MacOS',) %}
    - group: {{ sqldeveloper.prefs.group }}
       {% endif %}
    - mode: 644
    - require_in:
      - file: sqldeveloper-product-conf

sqldeveloper-product-conf:
  file.managed:
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/.sqldeveloper/{{ sqldeveloper.oracle.release }}/product.conf
    - user: {{ sqldeveloper.prefs.user }}
       {% if sqldeveloper.prefs.group and grains.os not in ('MacOS',) %}
    - group: {{ sqldeveloper.prefs.group }}
       {% endif %}
    - mode: 644
    - contents:
      - SetJavaHome /usr/lib/java

sqldeveloper-product-conf-permissions:
  file.directory:
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/.sqldeveloper
    - mode:  744
    - user: {{ sqldeveloper.prefs.user }}
    {% if grains.os_family in ('Suse',) or grains.os in ('SUSE',) %}
    - group: users
    {% elif grains.os_family == 'MacOS' %}
    - group: {{ macgroup }}
    {% else %}
    - group: {{ sqldeveloper.prefs.group }}
    {% endif %}
    - recurse:
      - user
      - group
      - mode
    - onchanges:
      - sqldeveloper-product-conf-dir

      {% if sqldeveloper.prefs.xmlurl or sqldeveloper.prefs.xmldir %}
         {% set connections_xml = sqldeveloper.homes ~ '/' ~ sqldeveloper.prefs.user ~ '/' ~ sqldeveloper.prefs.xmlfile %}

sqldeveloper-prefs-xmlfile:
  file.managed:
    - onlyif: test -f {{ sqldeveloper.prefs.xmldir }}/{{ sqldeveloper.prefs.xmlfile }}
    - name: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/{{ sqldeveloper.prefs.xmlfile }}
    - source: {{ sqldeveloper.prefs.xmldir }}/{{ sqldeveloper.prefs.xmlfile }}
    - user: {{ sqldeveloper.prefs.user }}
    - makedirs: True
        {% if grains.os_family in ('Suse',) %}
    - group: users
        {% elif grains.os_family == 'MacOS' %}
    - group: {{ macgroup }}
        {% else %}
    - group: {{ sqldeveloper.prefs.group }}
        {% endif %}
    - if_missing: {{ sqldeveloper.homes }}/{{ sqldeveloper.prefs.user }}/{{ sqldeveloper.prefs.xmlfile }}
  cmd.run:
    - unless: test -f {{ sqldeveloper.prefs.xmldir }}/{{ sqldeveloper.prefs.xmlfile }}
    - name: curl -o {{ connections_xml }} {{sqldeveloper.prefs.xmlurl}}
    - runas: {{ sqldeveloper.prefs.user }}
    - if_missing: {{ connections_xml }}
      {% endif %}

   {% endif %}
{% endif %}

