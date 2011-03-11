# apache_helper
A little helper script to set up common configurations for Mac OS Apache local dev environments.

## Commands
	add vhost            Add new VirtualHost
	edit conf            Opens Apache's configuration file in your editor.
	edit hosts           Opens hosts file in your editor.
	edit userconf        Opens user-specific configuration file in your editor.
	help                 Display global or [command] help documentation.
	php                  Modifies Apache configuration to enable PHP support.
	setup userconf       Configures Apache to load a user-specific configuration file.

## Setup

First, run `apache_helper.rb setup userconf`. This generates a file "apache.conf" in your home directory and modifies Apache's main configuration to load it. This makes it easier to keep track of all the VirtualHosts you have defined.

If you plan to develop PHP sites, run `apache_helper.rb php` to enable the PHP module in Apache's configuration. (It is disabled by default in Mac OS.)

Then, to add new virtual hosts, you can use the "add vhost" command:

	apache_helper.rb add vhost myproject.local --path /Users/me/Sites/myproject/htdocs

If you're setting up a Rails project (served by the Passenger Apache module) use the --rails flag:

	apache_helper.rb add vhost myproject.local --rails --path /Users/me/Sites/myproject

You don't need to point it to the "public" folder; it finds that automatically. The path should just be the root of your Rails app.