.. toctree::
   :maxdepth: 2

=========
Debugging
=========

This is a guideline on how to go about managing and maintaining the many python
packages in rocon without it becoming edible fodder for the `flying spaghetti monster`_.

Overview
========

Debugging and maintaining working code in rocon is hard for several reasons:

* RoS is a distributed system and rocon multimaster takes this to another level

  * Traditional debuggers are of minimal use.

* Python code 

  * Doesn't catch many errors at compile time, effects of one small change can be hidden for a long time
  * Type errors (wrong types going into functions) happen all the time
  * ...

The biggest hurdle is the distributed nature of a runtime rocon system and the time consumed in
actually running a rocon system (multiple robots!). The key is to get your code tested
and working on your pc before you put it onto the runtime system and then have the runtime
system throw enough information when something's gone wrong so that you can move back
to the pc for testing and debugging (lots of *useful* exception handling and logging!).

Guidelines
==========

* IDE automatic **indexing** and **code analysis** - see errors before running the code.
* Use `roslint_python`_ to do code analysis when building with catkin_make.
* Keep python modules small - any testable unit shouldn't grow too complex so as to avoid crazy debugging
* Write code so that **non-ros** content and **ros** content are decoupled

  * RoS classes should just be wrappers with params and callbacks that utilise the non-ros classes.

* Do lots of careful exception handling so you can report what is going wrong and where.
* Follow a **test-driven philosophy**: test first, then code it.

  * **nosetests** for your non-ros classes.
  * **rostests** to test your pubsub/service callbacks.
  * `rocon_test`_ for testing multimaster functionality.

Some examples of good test suites:

* Jack's `concert_scheduling`_ and the `rocon_interactions`_ packages are good examples of nose/rostests
* The `rocon_gateway_tests`_ package is a good example of rocon tests.


Tips
====

Roslint
-------

In CMakeLists.txt:

.. code-block:: cmake

   file(GLOB_RECURSE ${PROJECT_NAME}_MODULE_SOURCES RELATIVE ${PROJECT_SOURCE_DIR} src/*.py)
   file(GLOB_RECURSE ${PROJECT_NAME}_SCRIPT_SOURCES RELATIVE ${PROJECT_SOURCE_DIR} scripts/*)
   roslint_python(${${PROJECT_NAME}_MODULE_SOURCES} ${${PROJECT_NAME}_SCRIPT_SOURCES})

In package.xml:

.. code-block:: xml

   <build_depend>roslint</build_depend>


Pydev
-----

**Running**

* Source `setup.bash` before running eclipse, e.g. the following script will do the job

.. code-block:: bash

   export WORKSPACE=/mnt/zaphod/ros/rocon
   if [ -d ${WORKSPACE}/devel ]; then
     source ${WORKSPACE}/devel/setup.bash
   fi
   exec /opt/eclipse/eclipse -data ~/workspace/rocon

**Global Preferences**

* Preferences->Pydev->Interpreters->Python->Quick Config and apply

  * If you sourced setup.bash, it should automatically pick up the correct python, the ros python path and your devel path.

* Preferences->Pydev->Editors->Code Analysis

  * Select warning level
  * Add `--ignore=E501,E221` to the arguments (ignores too long lines, whitespace aligned formatting) if these bother you

**Pydev Projects**

* Create a pydev project for each python catkin package.
* Project Properties->Project References : select all other pydev projects (catkin python packages) that it depends on.
* Project Properties->Pydev PYTHONPATH : add both src and scripts (or bin) directories.


.. _`flying spaghetti monster`: http://en.wikipedia.org/wiki/Flying_Spaghetti_Monster
.. _`concert_scheduling`: https://github.com/utexas-bwi/concert_scheduling/tree/master/concert_scheduler_requests
.. _`rocon_gateway_tests`: https://github.com/robotics-in-concert/rocon_multimaster/tree/hydro-devel/rocon_gateway_tests/tests
.. _`rocon_interactions`: https://github.com/robotics-in-concert/rocon_tools/tree/hydro-devel/rocon_interactions/tests
.. _`rocon_test`: http://wiki.ros.org/rocon_test
.. _`roslint_python`: http://wiki.ros.org/roslint