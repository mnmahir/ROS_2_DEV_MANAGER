# Development Manager for ROS 2
Development manager for ROS 2 workspace.

## Basic Setup
1. Install `git` and `gh`:
   ```
   sudo apt install git gh -y
   ``` 
2. Login to github account (Recommended to clone private repo easily):
    ```
    gh auth login
    ```
3. Create an empty folder.
4. `cd` into the created folder.
5. Clone this repo as `dev_manager`:
    ```
    git clone https://github.com/MIMOSRobotics/DEVELOPMENT-MANAGER-ROS-2.git dev_manager
    ```
6. `cd` into `dev_manager` dir and run `dev_init.bash` by:
    ```
    source dev_init.bash
    ```
    OR
    ```
    . dev_init.bash     # NOT ./dev_init.bash!
    ```
7. Type `r2dev` in terminal to open development manager menu.
   1. If ROS 2 is not yet installed, choose `1`.
   2. You may install recommended software by choosing `2`.
   3. Clone a pre-defined project repo, choose `3`. Then, choose desired repo to clone.
      1. Accept adding alias to `.bashrc` automatically.
8. If you are not initialize to the new repo, initialize it with the added alias.
9.  Done! Your project is ready!

## Default Aliases
After initializing the workspace, these are useful aliases to use for rapid development. Additional or modified aliases can be done in project repo under `config` folder.
|Alias|Description|
|-|-|
|`r2dev`|To open development manager.|
|`r2pkg`|To open package manager.|
|`r2s`|Source the `setup.bash` or `local_setup.bash` of ROS environment, currently initialized workspace, `pkg` directories and active workspace (eg: `ws_robot`) workspace. |
|`r2sros`|Source ROS environment.|
|`r2sinfo`|Show information of current active project and workspace.|
|`r2salias`|Currently only show list of aliases that begins with `r2`.|

Operation on project repo directory.
|Alias|Description|
|-|-|
|`r2b`|Colcon build in the initialized `ws_...` workspace.|
|`r2bf`|Same as `r2b` but will run `rosdep` update and install first (Install dependencies). Recommended for first time setup so that all dependencies is installed before building the package.|
|`r2del`|Delete `build`, `install` and optional `log` directory from active `ws_...` workspace directory. Recommended to restart terminal to completely remove traces of sourced packages.|
|`r2cdw`|Change directory to active workspace directory (`ws_...`).|
|`r2cdr`|Change directory to active project directory (eg: `project_repo`).|


## Folder Structure
Recommended to place this development manager repo within the same directory as project repo as shown below:
<pre>
WORKSPACE
├── dev_manager (development manager repo)
|   ├── config
|   ├── scripts
|   ├── template   (project repo template)
|   |   ├── config
|   |   ├── pkg
|   |   ├── ws_robot
|   |   └── ...
|   ├── dev_init.bash
|   └── ...
├── project_repo_1 (project repo)
|   ├── config
|   ├── pkg
|   ├── ws_robot
|   └── ...
├── project_repo_2 (project repo)
|   ├── config
|   ├── pkg
|   ├── ws_robot
|   └── ...
└── project_repo_3 (project repo)
    ├── config
    ├── pkg
    ├── ws_robot
    └── ...
</pre>

To use the dev manager, add alias using below format into `.bashrc`:
```
<alias>='source <dev_init_path> <repo dir> <ws dir>'
```
where `<repo dir>` dir is relative to WORKSPACE dir and `<ws dir>` dir is relative to working repo dir.

eg:
```
alias wsrobot='source ~/WORKSPACE/dev_manager/dev_init.bash /project_repo_1 /ws_robot'
alias wsrobot='source ~/WORKSPACE/dev_manager/dev_init.bash /project_repo_2 /ws_robot'
alias wsrobot='source ~/WORKSPACE/dev_manager/dev_init.bash /project_repo_3 /ws_robot'
```
## Project Repo Guideline
The project repo must follow the same structure as template. Inside the template contains pre-defined variables for development manager to consume.

Please use the template given if you are creating a new project.

## TODO
- Write more info.
- Add more info to Lab's OneNote.