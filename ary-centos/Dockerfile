FROM centos:6.6
MAINTAINER Lakshman Kumar <lakshmankumar@gmail.com>

# Install dev tools
RUN yum -y install tar vim sudo && yum clean all

RUN yum -y groupinstall "Development Tools" || true  && yum clean all

RUN yum -y install screen gcc-c++ svn texinfo-tex flex zip libgcc.i686 glibc-devel.i686 wget clang || true && \
      yum clean all

RUN mkdir /var/shared/ && \
    touch /var/shared/placeholder

VOLUME /var/shared

CMD ["/bin/bash"]
