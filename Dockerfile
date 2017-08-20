FROM centos:7
MAINTAINER Alexandr Motov <alexandr.motov@gmail.com>

RUN yum update -y && \
    yum install -y java-1.8.0-openjdk-headless && \
    yum install -y java-1.8.0-openjdk-devel git wget curl unzip which && \
    yum clean all
    
ENV MVN_VERSION=3.5.0
ENV MVN_URL=http://www-us.apache.org/dist/maven/maven-3/${MVN_VERSION}/binaries

RUN mkdir -p /usr/share/maven && \
    curl -fsSL -o /tmp/apache-maven.tar.gz ${MVN_URL}/apache-maven-${MVN_VERSION}-bin.tar.gz && \
    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 && \
    rm -f /tmp/apache-maven.tar.gz && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN groupadd -g 1001 fm && \
    adduser -u 1001 -g 1001 -d /usr/share/fm fm

ENV FM_HOME=/usr/share/fm \
    FM_REPO_URL=https://github.com/amotov/file-manager.git

WORKDIR /tmp/file-manager-source
RUN git init && \
    git remote add origin ${FM_REPO_URL} && \
    git fetch && \
    git checkout -t origin/master && \
    mvn install

WORKDIR $FM_HOME
ENV PATH $FM_HOME/bin:$PATH

RUN unzip -d "$KM_HOME" "/tmp/file-manager-source/target/file-manager.zip"; \
    f=("$FM_HOME"/*); \
    mv "$FM_HOME"/*/* "$FM_HOME"; \
    rmdir "${f[@]}"

RUN yum autoremove -y java-1.8.0-openjdk-devel apache-maven git wget unzip which; \
    yum clean all

RUN chmod a+x ./bin/start.sh; \
    for path in \
        ./bin \
        ./config \
        ./files/dynamic \
        ./files/static \
        ./lib \
        ./logs \
    ; do \
        mkdir -p "$path"; \
        chown -R fm:fm "$path"; \
    done;

USER fm

CMD ["start"]

EXPOSE 8080
