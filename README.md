[![Build Status](http://img.shields.io/travis/cchurch/ansible-role-uwsgi.svg)](https://travis-ci.org/cchurch/ansible-role-uwsgi)
[![Galaxy](http://img.shields.io/badge/galaxy-cchurch.uwsgi-blue.svg)](https://galaxy.ansible.com/list#/roles/4388)

uWSGI
=====

Install uWSGI in emperor mode and configure vassals.

Role Variables
--------------

The following variables may be defined to customize this role:

- `uwsgi_name`: Name of uWSGI Upstart service, default is `uwsgi`, required.
- `uwsgi_description`: Description for uWSGI Upstart service, default is
  `uWSGI Server`.
- `uwsgi_service_name`: Name of uWSGI service, default is `uwsgi` unless an OS
  package is installed that defines an alternate service name.
- `uwsgi_use_upstart`: Boolean indicating whether to use Upstart to create and
  manage uWSGI service.  Undefined by default, will be set to false if an OS
  package is installed that already provides an init script, otherwise true.
- `uwsgi_install`: Method to use to install uWSGI, can be `pkg` (default) to
  use system package manager or `pip` to install via pip.  Any other value
  assumes uWSGI is installed via other means.
- `uwsgi_version`: When specified, install a specific version of uWSGI.
- `uwsgi_virtualenv`: When specific and `uwsgi_install` == `pip`, installs
  uWSGI into the specific virtualenv.
- `uwsgi_bin`: Path to uWSGI binary to use for Upstart, will be determined
  automatically if not specified.
- `uwsgi_vassal_path`: Path for uWSGI Emperor to look for vassal configuration
  files, default is `/etc/uwsgi` unless installed from an OS package, in
  which case an OS-specific default will be used.
- `uwsgi_opts`: Command line options to be used when running uWSGI via
  Upstart.  Defaults to running emperor in master mode:
  `--master --die-on-term --emperor {{uwsgi_vassal_path|quote}}`.
- `uwsgi_vassals`: Create INI configuration files for any vassals specified.
  Must be a list of hashes, with each hash having at least a `name` key to
  specify file name.  All keys and values are written to the INI file under
  the `[uwsgi]` section.  Default is `[]`.

Example Playbook
----------------

The following example playbook installs uWSGI via pip and configures a single
vassal running a Django site:

    - hosts: all
      roles:
        - role: cchurch.uwsgi
          uwsgi_install: pip
          uwsgi_vassals:
            - name: example
              plugin: python
              chdir: /opt/example/src
              module: example.wsgi
              home: /opt/example/env
              env: DJANGO_SETTINGS_MODULE=example.settings
              processes: 4
              socket: 127.0.0.1:8000
              uid: example_user
              gid: example_group

License
-------

BSD

Author Information
------------------

Chris Church <chris@ninemoreminutes.com>
