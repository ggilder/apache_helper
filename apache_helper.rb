#!/usr/bin/env ruby

begin
	require 'commander/import'
rescue LoadError
	puts "The commander gem is not installed. Please install it using:"
	puts "\tgem install commander"
	exit
end

begin
	require 'ftools'
rescue LoadError
	require 'fileutils'
end
require 'tempfile'


program :name, 'Apache Helper'
program :version, '0.0.1'
program :description, 'Helper script to set up common configurations for Mac OS Apache local dev environments.'

command :php do |c|
	c.syntax = File.basename($0)+' php'
	c.description = 'Displays foo'
	c.action do |args, options|
		ApacheHelper::PHPHelper.enable
	end
end

command :'add vhost' do |c|
	c.description = 'Add new VirtualHost'
	c.option '--path STRING', String, 'Path to serve for this VirtualHost'
	c.action do |args, options|
		options.default :path => '/Library/WebServer/Documents'
		if (!args.first)
			say "Please specify a host name to add."
		else
			say "Adding new VirtualHost #{args.first} with document root #{options.path}"
			say "Oops, this isn't implemented yet. Sorry!"
		end
	end
end

module FileHelper
	def FileHelper.read_file(filepath)
		contents = ''
		File.open(filepath, 'r') {|f| contents << f.read }
		contents
	end
	
	def FileHelper.write_protected_file(filepath, contents)
		tempfile = Tempfile.new(File.basename(filepath)+"_temp")
		tempfile.write(contents)
		tempfile.close
		
		puts `cat #{tempfile.path} | sudo tee #{filepath} > /dev/null`
		tempfile.unlink
	end
	
	def FileHelper.backup_file(filepath)
		bakfile = FileHelper.get_backup_filepath(filepath)
		puts `cp "#{filepath}" "#{bakfile}"`
		bakfile
	end
	
	def FileHelper.backup_protected_file(filepath)
		bakfile = FileHelper.get_backup_filepath(filepath)
		puts `sudo cp "#{filepath}" "#{bakfile}"`
		bakfile
	end
	
	def FileHelper.get_backup_filepath(filepath)
		File.dirname(filepath) + '/' + File.basename(filepath, File.extname(filepath)) + '_bak_' + Time.now.to_i.to_s + File.extname(filepath)
	end
end

module ApacheHelper
	APACHE_CONF_PATH = '/private/etc/apache2/httpd.conf'
	def ApacheHelper.read_conf
		FileHelper.read_file(APACHE_CONF_PATH)
	end
	
	def ApacheHelper.write_conf(contents)
		bakfile = FileHelper.backup_protected_file(APACHE_CONF_PATH)
		FileHelper.write_protected_file(APACHE_CONF_PATH, contents)
	end
	
	def ApacheHelper.restart
		puts `sudo apachectl restart`
	end

	module PHPHelper
		ENABLED = '#LoadModule php5_module libexec/apache2/libphp5.soz'
		TEST_FOR = %r{^\s*#{ENABLED.gsub(/\s/,'\\s+')}\s*$}
		COMMENTED = %r{^\#\s*#{ENABLED.gsub(/\s/,'\\s+')}\s*$}

		def PHPHelper.enable
			conf_contents = ApacheHelper.read_conf
			if (conf_contents =~ TEST_FOR)
				say "Your Apache configuration already has the PHP module enabled. Yay!"
			else
				answer = agree("Your Apache configuration does not seem to have the PHP module enabled. Do you want to enable it? (y/n)")
				if answer
					if conf_contents =~ COMMENTED
						conf_contents.sub!(COMMENTED, ENABLED)
					else
						conf_contents << ENABLED
					end
					
					ApacheHelper.write_conf(conf_contents)
					say "Modified your Apache configuration. Previous configuration backed up."
					
					say "Restarting Apache..."
					ApacheHelper.restart
					say "Ok, have fun!"
				else
					say "Ok, bye then."
				end
			end
		end
	end
end

# TODO
# add vhosts:
# NameVirtualHost *:80
# passenger style
# <VirtualHost *:80>
# 	 ServerName domain.local
# 	 DocumentRoot /Users/username/Sites/domain/rails/public
# 	 ErrorLog "/Users/username/Sites/domain/rails/log/error_log"
# 	 CustomLog "/Users/username/Sites/domain/rails/log/access_log" common
# 	RailsEnv development
# 	 <Directory /Users/username/Sites/domain/rails/public>
# 			AllowOverride all
# 			Options -MultiViews
# 	 </Directory>
# </VirtualHost>
# normal
# <VirtualHost *:80>
# 	DocumentRoot "/Users/username/Sites/domain/htdocs"
# 	ServerName domain.local
# 	ErrorLog "/var/log/apache2/domain.local.error_log"
# 	CustomLog "/var/log/apache2/domain.local.access_log" common
# 
# 	<Directory "/Users/username/Sites/domain/htdocs">
# 		Options MultiViews Indexes SymLinksIfOwnerMatch
# 		AllowOverride all
# 	</Directory>
# </VirtualHost>
# on a specific port
# Listen 9999
# <VirtualHost *:9999>
# No ServerName, etc...
