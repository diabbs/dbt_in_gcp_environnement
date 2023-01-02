FROM python:3.9

ARG user=user1
ARG organization=https://github.com/diabbs
ARG repo=dbt_in_gcp_environnement

ARG homedir=/home/${user}
COPY entrypoint.sh ${homedir}

# Non-root group & user creation
RUN groupadd -r ${user}
RUN useradd -r -m -g ${user} ${user}
RUN mkdir ${homedir}
RUN mkdir ${homedir}/.ssh

# Git
ENV REMOTE_REPO git@github.com:${organization}/${repo}.git
ENV REPO_DIR ${homedir}/${repo}
RUN apt-get update && apt-get install -y git
COPY id_rsa ${homedir}/.ssh/
RUN ssh-keyscan github.com >> ${homedir}/.ssh/known_hosts

# BigQuery
ENV GOOGLE_APPLICATION_CREDENTIALS ${homedir}/service_account.json
COPY service_account.json ${homedir}

# Permissions!
RUN chmod 0700 ${homedir}/.ssh
RUN chmod 0600 ${homedir}/.ssh/id_rsa
RUN chmod 0644 ${homedir}/.ssh/known_hosts
RUN chmod 0755 ${homedir}/entrypoint.sh
RUN chown -R ${user}:${user} ${homedir}/.ssh

# DBT!
RUN pip install dbt==0.11.1

# Prep for container execution
USER ${user}
WORKDIR ${homedir}
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]