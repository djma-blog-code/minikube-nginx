Changelog
=========


(unreleased)
------------
- Merge(feature): Added multihost, merging branch. [Mike Arnold]


1.3.0 (2021-03-22)
------------------

Features
~~~~~~~~
- Multihost : Add multi host routing + tls. [Mike Arnold]


Documentation
~~~~~~~~~~~~~
- README : Link stages to tags in github. [Mike Arnold]

- README : Add in purpose statement. [Mike Arnold]

- README : Add in new make recipe. [Mike Arnold]

- README : Updated to reference the ytemplate. [Mike Arnold]

- Changelog : Update changelog. [Mike Arnold]


Fixes
~~~~~
- Makefile : Fix incorrect clean, add set namespace. [Mike Arnold]


Other
~~~~~
- Tidy(Makefile): Remove old Variables, not required. [Mike Arnold]


1.2.0 (2021-03-22)
------------------

Features
~~~~~~~~
- Changelog : Add changelog and make recipe. [Mike Arnold]


Documentation
~~~~~~~~~~~~~
- READEME : Add the pesky space (formatting) [Mike Arnold]

- README : fix the 'autolint' fixes ... *sigh* [Mike Arnold]

- README : Minor typo... [Mike Arnold]

- README : Add link to changelog (can't include :() [Mike Arnold]

- README : add link to gitchangelog. [Mike Arnold]


Fixes
~~~~~
- Makefile : Fix lint recipe (dependencies) [Mike Arnold]


1.1.0 (2021-03-22)
------------------

Features
~~~~~~~~
- Templated : Add templated build feature. [Mike Arnold]

  Also tidied up some of the Makefile and added lint checker.

Documentation
~~~~~~~~~~~~~
- README : Removed sudo example as it doesn't work... [Mike Arnold]

- README : Really need to learn to type/proof read. [Mike Arnold]

- README : Add issue with read only filesystem. [Mike Arnold]

- README : Added some useful links. [Mike Arnold]

- README : Updated TODO list to remove repetition. [Mike Arnold]

  Too much repetition in the Makefile, but for v1 it works...
- README : Another minor typo. [Mike Arnold]

- README : Minor typo. [Mike Arnold]


Other
~~~~~
- Merge(oops): 2 repos out of sync .... don't edit in the browser *sigh* [Mike Arnold]

- Refactor(Makefile): Tidy up and remove redundancy. [Mike Arnold]

  Refactored Makfile to tidy up the recipes and remove repetition
- Refactor(templating): Add templating to yaml. [Mike Arnold]

  Introduce templates and a `make yaml` command to allow for dynamic
  inclusion of environment variables in the yaml files (e.g. namesapce which may change through ci/cd pipeline)

1.0.2 (2021-03-21)
------------------

Documentation
~~~~~~~~~~~~~
- README : Some minor tweaks. [Mike Arnold]


1.0.1 (2021-03-21)
------------------

Documentation
~~~~~~~~~~~~~
- README : Update readme with useful info. [Mike Arnold]


1.0.0 (2021-03-21)
------------------

Features
~~~~~~~~
- Nginx : Add basic nginx deployment and Makefile. [Mike Arnold]


Other
~~~~~
- Initial(README): Initial blank readme to start things off. [Mike Arnold]

- Initial commit. [Mike Arnold]


