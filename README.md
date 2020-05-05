# ros2_tools
Tools for version 2 of the Robot Operating System (ROS)

## ros2_quick_setup.sh
This script allows to quickly set the environment for ROS 2 itself and other workspaces. (Intended to use with a standard ROS 2 installation on Ubuntu from the official repository.)

Example: You have ROS 2 Eloquent Elusor installed in `/opt/ros` and a custom workspace in `/home/user/my_workspace`. Then add the following lines to `~/.bashrc` (adjust PATH):

```sh
source PATH/ros2_quick_setup.sh
setup_ros2_environment /opt/ros/ eloquent
add_ros2_workspace /home/user/my_workspace
```
