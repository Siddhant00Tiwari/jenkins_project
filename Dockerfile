FROM rockylinux:8


# Install packages
RUN dnf install -y httpd git && dnf clean all

RUN git clone https://github.com/Siddhant00Tiwari/Static-website.git
# Copy the zip file  container
RUN cp -rvf Static-website/* /var/www/html/

WORKDIR /var/www/html

# Copy contents of markups-kindle directory to current directory
#RUN cp -rvf Static-website/ &&
RUN rm -rf Static-website  __MACOSX

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
