The directory contains hooks used by Docker Hub when building images:

    Docker Hub allows you to override and customize the `build`, `test` and `push`
    commands during automated build and test processes using hooks. For
    example, you might use a build hook to set build arguments used only during
    the build process. (You can also set up custom build phase hooks to perform
    actions in between these commands.)

    Use these hooks with caution. The contents of these hook files replace the
    basic `docker` commands, so you must include a similar build, test or push
    command in the hook or your automated process does not complete.

    To override these phases, create a folder called `hooks` in your source code
    repository at the same directory level as your Dockerfile. Create a file
    called `hooks/build`, `hooks/test`, or `hooks/push` and include commands that the
    builder process can execute, such as `docker` and `bash` commands (prefixed
    appropriately with `#!/bin/bash`).

    These hooks will be running on an instance of Amazon Linux 2, a distro
    based on Ubuntu, which includes interpreters such as Perl and Python and
    utilities such as git or curl. Please check the link above for the full
    list.

# See also

* https://docs.docker.com/docker-hub/builds/advanced
* https://stackoverflow.com/questions/59057978/passing-source-commit-to-dockerfile-commands-on-docker-hub
