#!/bin/bash
LIST_GIT_REPO=(     # List of git repositories to be cloned ("Git URL" "Commit ID/Tag/Branch"). Preferably use commit id / tag for reproducibility.
    # For tracking purpose always use commit id and please add comment at the end # <git branch> <tag if available> (<date of changing this list>)
)


LIST_APT_PKG=(  # List of apt packages to be installed ("Package Name" "--optional-flag")
)


LIST_PYTHON_PKG=(   # List of python packages to be installed ("Package Name" "--optional-flag")
)


LIST_EXEC_CMD_PRE=(     # List of commands to be executed ("Command") before running Git, APT or Python Installation
)

LIST_EXEC_CMD_POST=(     # List of commands to be executed ("Command") after running Git, APT or Python Installation
)