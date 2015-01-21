Rocon
=====

This is a meta-repo for rosinstallers, packaging and organisation-wide issues, discussions and documents.

## Installation
#### ROS installation (indigo)

http://wiki.ros.org/indigo/Installation/Ubuntu

#### Useful packages

* yujin_tools
  * https://github.com/yujinrobot/yujin_tools
* roslint
  * http://wiki.ros.org/roslint
  * ```> sudo apt-get install ros-<version>-roslint```

#### Rocon Installation
  
  ```
  > yujin_init_workspace rocon_ws https://raw.githubusercontent.com/robotics-in-concert/rocon/indigo/rocon.rosinstall
  > cd rocon_ws
  > yujin_init_build .
  > . .bashrc
  > yujin_make --install-rosdeps
  > yujin_make
  > . .bashrc
  ```
  
