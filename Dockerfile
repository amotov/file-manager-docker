FROM centos:7
MAINTAINER Alexandr Motov <alexandr.motov@gmail.com>

RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo; \
    yum update -y; \
    yum install -y java-1.8.0-openjdk-headless; \
    yum install -y java-1.8.0-openjdk-devel apache-maven git wget unzip which; \
    yum clean all

RUN groupadd -g 10000 fm && \
    adduser -u 10000 -g 10000 -d /usr/share/fm fm

ENV FM_HOME=/usr/share/fm \
    FM_REPO_URL=https://github.com/amotov/file-manager.git \
    JAVA_HOME=/usr/java/default/

WORKDIR /tmp/file-manager-source
RUN git init; \
    git remote add origin ${FM_REPO_URL}; \
    git fetch; \
    git checkout -t origin/master

WORKDIR $FM_HOME
ENV PATH $FM_HOME/bin:$PATH

RUN wget -O kafka-manager-source.tar.gz "https://github.com/yahoo/kafka-manager/archive/${KM_VERSION}.tar.gz"; \
    tar -zxvf kafka-manager-source.tar.gz --strip-components=1; \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt; \
    ./sbt clean dist

RUN groupadd -g 10000 km && adduser -u 10000 -g 10000 -d /usr/share/kafka-manager km

WORKDIR /usr/share/kafka-manager
ENV PATH $KM_HOME/bin:$PATH

RUN unzip -d "$KM_HOME" "/tmp/kafka-manager-source/target/universal/kafka-manager-${KM_VERSION}.zip"; \
    f=("$KM_HOME"/*); \
    mv "$KM_HOME"/*/* "$KM_HOME"; \
    rmdir "${f[@]}"

RUN rm -fr /tmp/* /root/.sbt /root/.ivy2
RUN yum autoremove -y java-1.8.0-openjdk-devel git wget unzip which; \
    yum clean all

ADD ./bin/kafka-manager-start.sh ./bin/kafka-manager-start.sh
RUN chmod a+x ./bin/kafka-manager-start.sh; \
    for path in \
        ./bin \
        ./conf \
        ./lib \
        .logs \
        ./share \
    ; do \
        mkdir -p "$path"; \
        chown -R km:km "$path"; \
    done;

USER km

CMD ["kafka-manager"]

EXPOSE 9000