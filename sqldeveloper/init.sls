{% from "sqldeveloper/map.jinja" import sqldeveloper with context %}

sqldeveloper-create-extract-dirs:
  file.directory:
    - names:
      - '{{ sqldeveloper.tmpdir }}'
      - '{{ sqldeveloper.oracle.home }}'
  {% if grains.os not in ('MacOS', 'Windows',) %}
      - '{{ sqldeveloper.oracle.realhome }}'
    - user: root
    - group: root
    - mode: 755
  {% endif %}
    - clean: True
    - makedirs: True

{% for pkg in sqldeveloper.oracle.pkgs %}

  {% set url = sqldeveloper.oracle.uri ~ pkg ~ '-' ~ sqldeveloper.oracle.version ~ '-' ~ sqldeveloper.arch ~ '.' ~ sqldeveloper.dl.suffix %}

sqldeveloper-extract-{{ pkg }}:
  cmd.run:
    - name: curl {{sqldeveloper.dl.opts}} -o '{{ sqldeveloper.tmpdir }}{{ pkg }}.{{sqldeveloper.dl.suffix}}' {{ url }}
    {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
      attempts: {{ sqldeveloper.dl.retries }}
      interval: {{ sqldeveloper.dl.interval }}
    {% endif %}
    {%- if grains['saltversioninfo'] <= [2016, 11, 6] %}
      # Check local archive using hashstring for older Salt
      # (see https://github.com/saltstack/salt/pull/41914).
  module.run:
    - name: file.check_hash
    - path: '{{ sqldeveloper.tmpdir }}{{ pkg }}.{{ sqldeveloper.dl.suffix }}'
    - file_hash: {{ sqldeveloper.oracle.md5[ pkg ] }}
    - onchanges:
      - cmd: sqldeveloper-extract-{{ pkg }}
    - require_in:
      - archive: sqldeveloper-extract-{{ pkg }}
    {%- endif %}
  archive.extracted:
    - source: file://{{ sqldeveloper.tmpdir }}{{ pkg }}.{{sqldeveloper.dl.suffix}}
    - name: '{{ sqldeveloper.prefix }}'
    - archive_format: {{ sqldeveloper.dl.archive_type }}
        {% if grains['saltversioninfo'] < [2016, 11, 0] %}
    - if_missing: '{{ sqldeveloper.oracle.realcmd }}'
        {% endif %}
        {% if grains['saltversioninfo'] >= [2016, 11, 0] %}
    - enforce_toplevel: False
        {% endif %}
        {%- if grains['saltversioninfo'] > [2016, 11, 6] %}
         #Check local archive using hashstring or hashurl
    - source_hash: {{ sqldeveloper.oracle.md5[ pkg ] }}
        {% endif %}
    - onchanges:
      - cmd: sqldeveloper-extract-{{ pkg }}
    - require_in:
      - file: sqldeveloper-extract-{{ pkg }}
  file.absent:
    - name: '{{sqldeveloper.tmpdir}}/{{ pkg }}.{{sqldeveloper.dl.suffix}}'
    - onchanges:
      - archive: sqldeveloper-extract-{{ pkg }}
  {% if grains.os == 'MacOS' %}
    - require_in:
      - macpackage: sqldeveloper-install-sqldeveloper
  {% endif %}

{% endfor %}

  {% if grains.os == 'MacOS' %}
sqldeveloper-install-sqldeveloper:
  macpackage.installed:
    - name: '{{ sqldeveloper.prefix }}/SQLDeveloper.app'
    - store: False
    - dmg: False
    - app: True
    - force: True
    - allow_untrusted: True
    - require_in:
      - file: sqldeveloper-install-sqldeveloper
  file.absent:
     # source macapp no longer needed
    - name: '{{ sqldeveloper.prefix }}/SQLDeveloper.app'
  {% endif %}

