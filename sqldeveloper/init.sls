{% from "sqldeveloper/map.jinja" import sqldeveloper with context %}

sqldeveloper-create-extract-dirs:
  file.directory:
    - names:
      - '{{ sqldeveloper.tmpdir }}'
      - '{{ sqldeveloper.oracle.realhome }}'
  {% if grains.os not in ('MacOS', 'Windows') %}
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
    - name: curl {{sqldeveloper.dl.opts}} -o '{{sqldeveloper.tmpdir}}/{{ pkg }}.{{sqldeveloper.dl.suffix}}' {{ url }}
      {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
        attempts: {{ sqldeveloper.dl.retries }}
        interval: {{ sqldeveloper.dl.interval }}
      {% endif %}
    - require:
      - sqldeveloper-create-extract-dirs
    - require_in:
      - archive: sqldeveloper-extract-{{ pkg }}
  {% if sqldeveloper.dl.skip_hashcheck in ('None', 'False', 'false', 'FALSE') %}
  module.run:
    - name: file.check_hash
    - path: '{{ sqldeveloper.tmpdir }}/{{ pkg }}.{{ sqldeveloper.dl.suffix }}'
    - file_hash: {{ sqldeveloper.oracle.md5[ pkg ] }}
    - onchanges:
      - cmd: sqldeveloper-extract-{{ pkg }}
    - require_in:
      - archive: sqldeveloper-extract-{{ pkg }}
  {% endif %}
  archive.extracted:
    - source: 'file://{{ sqldeveloper.tmpdir }}{{ pkg }}.{{ sqldeveloper.dl.suffix }}'
    - name: '{{ sqldeveloper.prefix }}'
    - archive_format: {{ sqldeveloper.dl.suffix }}
       {% if grains['saltversioninfo'] >= [2016, 11, 0] %}
    - enforce_toplevel: False
       {% endif %}
    - require_in:
      - file: sqldeveloper-complete-sqldeveloper
 
{% endfor %}

