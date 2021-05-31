FROM debian

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Non-root user
ARG USERNAME=debian
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git vim sudo \
    dh-make build-essential git-buildpackage lintian equivs \
    #
    # Create a non-root user
    && groupadd --gid $USER_GID ${USERNAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    #
    # Add sudo support for the non-root user
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    #
    # Clean up
    # * Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
    #   https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

USER ${USERNAME}
WORKDIR /home/${USERNAME}

COPY build.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/build.sh" ]
