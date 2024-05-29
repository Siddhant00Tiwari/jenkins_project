FROM rockylinux:8


# Install packages
RUN dnf install -y httpd git && dnf clean all

RUN git clone https://github.com/praveenkpraveen31/docker-project.git
# Copy the zip file  container
RUN cp -rvf docker-project/* /var/www/html/

WORKDIR /var/www/html

# Copy contents of markups-kindle directory to current directory
#RUN cp -rvf static-website-example/ &&
RUN rm -rf docker-project  __MACOSX

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
