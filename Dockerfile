FROM registry.access.redhat.com/rhel7


ENV container oci
ENV PATH /usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

CMD ["/bin/bash"]

LABEL "BZComponent"="rhel-server-container" \
      "Name"="rhel7" \
      "Version"="7.9" 


#labels for container catalog
LABEL summary="Provides the latest release of Red Hat Enterprise Linux 7 in a fully featured and supported base image."
LABEL description="The Red Hat Enterprise Linux Base image is designed to be a fully supported foundation for your containerized applications. This base image provides your operations and application teams with the packages, language runtimes and tools necessary to run, maintain, and troubleshoot all of your applications. This image is maintained by Red Hat and updated regularly. It is designed and engineered to be the base layer for all of your containerized applications, middleware and utilities. When used as the source for all of your containers, only one copy will ever be downloaded and cached in your production environment. Use this image just like you would a regular Red Hat Enterprise Linux distribution. Tools like yum, gzip, and bash are provided by default. For further information on how this image was built look at the /root/anaconda-ks.cfg file."
LABEL io.k8s.display-name="Red Hat Enterprise Linux 7"
LABEL io.openshift.tags="base rhel7"



RUN    rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 \
    && yum -y install epel-release \
    && yum -y update \
    && yum -y install clamav-update clamd \
    && yum clean all

RUN    set -x \
    && cd /var/lib/clamav \
    && curl -O http://database.clamav.net/main.cvd \
    && curl -O http://database.clamav.net/daily.cvd \
    && curl -O http://database.clamav.net/bytecode.cvd \
    && curl -O http://database.clamav.net/safebrowsing.cvd \
    && chown clamupdate:clamupdate main.cvd daily.cvd bytecode.cvd safebrowsing.cvd \
    \
    && sed -ri ' \
            s/Example/#Example/g; \
            s/#Foreground/Foreground/g; \
            s/#LogTime/LogTime/g; \
            s/#TCPSocket/TCPSocket/g; \
            s/#StreamMaxLength 10M/StreamMaxLength 50M/g; \
            s/#MaxThreads 20/MaxThreads 50/g; \
            s/#ReadTimeout/ReadTimeout/g; \
            s/#DetectBrokenExecutables/DetectBrokenExecutables/g; \
            ' /etc/clamd.d/scan.conf \
    \
    && ln -s /etc/clamd.d/scan.conf /etc/clamd.conf

VOLUME ["/var/lib/clamav"]

EXPOSE 3310

ENTRYPOINT ["clamd"]
CMD []
