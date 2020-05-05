# prepend_to_exported_variable Variable Value
# Prepends Value to Variable with a colon as separator
# if Variable does not contain Value, yet:
#   Variable=Value:Variable
# If Variable does not exist or is empty, Value is assigned:
#   Variable=Value
function prepend_to_exported_variable {
    variable_name=$1
    if [ -z "${!variable_name}" ]; then
        # Create Variable if it is empty / does not exist, yet
        export $1=$2
    else
        # Append to Variable if it does not contain Value, yet
        if [[ ":${!variable_name}:" != *":$2:"* ]]; then
            export $1=$2:${!variable_name}
        fi
    fi
}

function append_to_pythonpath {
    nullglob_state="$(shopt -p nullglob)"
    shopt -s nullglob
    for python_dir in $1/python*/
    do
        if [ -d "${python_dir}site-packages" ]; then
            prepend_to_exported_variable PYTHONPATH "${python_dir}site-packages"
        fi
    done
    eval "$nullglob_state"
}

function add_ros2_workspace_common {
    package_path=$1
    package_name=$(basename $package_path)
    
    if [ -d "${package_path}/bin" ]; then
        prepend_to_exported_variable PATH "${package_path}/bin"
    fi
    
    if [ -d "${package_path}/lib" ]; then
        prepend_to_exported_variable LD_LIBRARY_PATH "${package_path}/lib"
        append_to_pythonpath "${package_path}/lib"
        
        if [ -d "${package_path}/lib/${package_name}" ]; then
            prepend_to_exported_variable PATH "${package_path}/lib/${package_name}"
        fi
    fi
    
    if [ -d "${package_path}/share/ament_index" ]; then
        prepend_to_exported_variable AMENT_PREFIX_PATH ${package_path}
    fi
}

function add_ros2_workspace {
    ros2_workspace_install_path="${1%/}/install" # 1%/ removes trailing slash if it exists
    
    if [ ! -d "$ros2_workspace_install_path" ]; then
        return
    fi
    
    prepend_to_exported_variable COLCON_PREFIX_PATH ${ros2_workspace_install_path}
    
    for dir in ${ros2_workspace_install_path}/*/
    do
        dir=${dir%*/} # remove trailing slash
        
        add_ros2_workspace_common ${dir}
        
        prepend_to_exported_variable CMAKE_PREFIX_PATH ${dir}
    done
}

# setup_ros2_environment RosBasePath RosVersion
# Example: setup_ros2_environment /opt/ros dashing
function setup_ros2_environment {
    ros_base_path=${1%/}
    ros_distro=$2
    ros_distro_path=$ros_base_path/$ros_distro
    
    export ROS_DISTRO=$ros_distro
    export ROS_PYTHON_VERSION=3
    export ROS_VERSION=2
    
    add_ros2_workspace_common $ros_distro_path
    
    source "$ros_distro_path/share/ros2cli/environment/ros2-argcomplete.bash"
}
