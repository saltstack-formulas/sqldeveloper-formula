========
sqldeveloper
========

Formula to download and configure the SQLDEVELOPER software from Oracle.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.
    
Available states
================

.. contents::
    :local:

``sqldeveloper``
------------
Downloads the archives from uri specified as pillar, unpack locally, and installs on the Operating System.

.. note::

This formula installs a specific version of sqldeveloper as default. Can be overridden by version pillar.

``sqldeveloper.developer``
------------
Create desktop shortcuts. Optionally download 'connections.xml' file from url/share to 'user' (pillar) home directory.


``sqldeveloper.linuxenv``
------------
On Linux, the PATH is set for all system users by adding software profile to /etc/profile.d/ directory. Full support for debian linuxenv in supported Linux distributions (i.e. not Archlinux).

.. note::

Enable Debian alternatives by setting nonzero 'altpriority' pillar value; otherwise feature is disabled.

Please see the pillar.example for configuration.
Tested on Linux (Ubuntu, Fedora, Arch, and Suse), MacOS. Not verified on Windows OS.
