# -*- coding: utf-8 -*-
# vim: ft=yaml
---
sqldeveloper:
  release: '12_2'      # quotes
  version: 17.3.1.279.0537
  environ:
    a: b
  identity:
    user: root
  linux:
    altpriority: 20000

  pkg:
    use_upstream_archive: true
    # in real world, this value cannot work (oracle login)
    uri: http://download.oracle.com/otn/java/sqldeveloper
    wanted:
      - sqldeveloper
      - sqlcl
    checksums:
      sqldeveloper: md5=5e077af62c1c5a526055cd9f810a3ee0
      sqlcl: md5=65862f2a970a363a62e1053dc8251078
