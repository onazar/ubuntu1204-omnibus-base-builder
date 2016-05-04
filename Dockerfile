# Use Ubuntu Precise
FROM ubuntu:12.04

## Basic Docker Setup for Ubuntu
# Disable Upstart
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y curl

## Prepare for Chef
RUN mkdir /root/chefrepo
ADD files/Cheffile /root/chefrepo/Cheffile
WORKDIR /root/chefrepo

## Create Omnibus Environment and Seppuku.
## (Delete chef to reduce image size.)
RUN eval "$(curl chef.sh)" && \
    /opt/chef/embedded/bin/gem install librarian-chef --no-ri --no-rdoc && \
    /opt/chef/embedded/bin/librarian-chef install && \
    chef-client -z -o "omnibus::default" && \
    rm -rf /opt/chef /root/chefrepo /root/.chef /root/.ccache /usr/local/src/*

## Preinstall gems
WORKDIR /root
ADD files/Gemfile /root/Gemfile
ADD files/prebundle.sh /root/prebundle.sh
RUN chmod 0777 /root/prebundle.sh
RUN ./prebundle.sh

ADD files/build.sh /home/omnibus/build.sh
RUN chmod 0777 /home/omnibus/build.sh

ENV HOME /home/omnibus

## ONBUILD to build project
ONBUILD ADD . /home/omnibus/omnibus-project

WORKDIR /home/omnibus/omnibus-project
ONBUILD RUN bash -c 'source /home/omnibus/load-omnibus-toolchain.sh; bundle install --binstubs bundle_bin --without development test'
ONBUILD RUN echo "Usage: docker run -it -e OMNIBUS_PROJECT=${PROJECT_NAME} -v pkg:/home/omnibus/omnibus-project/pkg omnibus_project-ubuntu1204"

CMD ["/home/omnibus/build.sh"]
