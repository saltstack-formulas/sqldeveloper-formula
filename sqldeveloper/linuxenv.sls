{% from "sqldeveloper/map.jinja" import sqldeveloper with context %}

{% if grains.os not in ('MacOS', 'Windows') %}

#runtime dependency
sqldeveloper-libaio1:
  pkg.installed:
    {% if grains.os in ('Ubuntu', 'Suse', 'SUSE') %}
    - name: libaio1
    {%- else %}
    - name: libaio
    {%- endif %}

# Update system profile with PATH
sqldeveloper-linux-profile:
  file.managed:
    - name: /etc/profile.d/sqldeveloper.sh
    - source: salt://sqldeveloper/files/sqldeveloper.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      home: '{{ sqldeveloper.oracle.home }}'
    - require:
      - pkg: sqldeveloper-libaio1

sqldeveloper-update-home-symlink:
  file.symlink:
    - name: '{{ sqldeveloper.oracle.home }}/sqldeveloper'
    - target: '{{ sqldeveloper.oracle.realhome }}'
    - force: True
    - require:
      - file: sqldeveloper-linux-profile

## Debian Alternatives ##

  {% if grains.os_family not in ('Arch') %}

# Add swhome to alternatives system
sqldeveloper-home-alt-install:
  file.directory:
    - name: {{ sqldeveloper.oracle.home }}
    - makedirs: True
  alternatives.install:
    - name: sqldeveloper-home
    - link: {{ sqldeveloper.oracle.home }}/sqldeveloper
    - path: {{ sqldeveloper.oracle.realhome }}
    - priority: {{ sqldeveloper.linux.altpriority }}
    - require:
      - file: sqldeveloper-home-alt-install

sqldeveloper-home-alt-set:
  alternatives.set:
    - name: sqldeveloper-home
    - path: {{ sqldeveloper.oracle.realhome }}
    - onchanges:
      - alternatives: sqldeveloper-home-alt-install

# Add to alternatives system
sqldeveloper-alt-install:
  alternatives.install:
    - name: sqldeveloper
    - link: {{ sqldeveloper.linux.symlink }}
    - path: {{ sqldeveloper.oracle.realcmd }}
    - priority: {{ sqldeveloper.linux.altpriority }}
    - require:
      - alternatives: sqldeveloper-home-alt-install
      - alternatives: sqldeveloper-home-alt-set

sqldeveloper-alt-set:
  alternatives.set:
    - name: sqldeveloper
    - path: {{ sqldeveloper.oracle.realcmd }}
    - onchanges:
      - alternatives: sqldeveloper-alt-install

  {% endif %}

{% endif %}

