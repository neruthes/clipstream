install_bin:
	install -m=755 ./bin/clipstream-admin-gentoken.sh /usr/bin/clipstream-admin-gentoken
	install -m=755 ./bin/pushclip.sh /usr/bin/pushclip

install_cgibin:
	mkdir -p /usr/lib/cgi-bin
	install -m=755 ./cgi-bin/gentoken.sh /usr/bin/clipstreamcgi-gentoken
	install -m=755 ./cgi-bin/saveclip.sh /usr/bin/clipstreamcgi-saveclip

install:
	make install_bin
	make install_cgibin
	mkdir -p /var/www/clipstream/www
	install -m=644 ./www/viewstream.html /var/www/clipstream/www/view.html

neruthes_install:
	make install
	install -m=644 ./conf/clipstream.nginx.conf /etc/nginx/sites-enabled/clipstream.conf
