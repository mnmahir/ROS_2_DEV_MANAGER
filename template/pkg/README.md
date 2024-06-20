# NOTE
This `pkg` directory is for placing functioning/production-ready packages to be consumed by the robot (`ws_robot`) and is not meant for frequent editing and changes. If you are developing a new package use existing or create a new `ws_...` directory instead. We recommend your awesome package to be highly reconfigurable/parameterized before adding it here. If the package allows loading parameters from a file, load the parameter file from `ws_...` instead.

The packages here has their own git repo. Some packages are general (like nav2) and some are very specific to a robot component (like robot controller). If you satisfied with the changes made in the package, make sure to test so they do not break other code/robot and don't forget to commit and push the changes of the package.

If you have an external package that does not have a git repo, create a repo for it. Then add the link and commit ID in `pkg_list.bash` script.

# Directory defintion
|Directory|Description|
|-|-|
|_others|General ROS2 packages that shares with different robots.|
|_robot|Packages that are specific to this robot such as driver packages to bringup certain robot components like sensors.|
|_sims|Packages for running simulation with this robot.|
|_tools|Tools to help in development/monitoring/etc.|
