#!/bin/bash

# @author: Salim Kapadia
# @date: 03/26/2012
# @version: 1.1
# @description - This program setups the server
#
#   How to Run:
#   ./createToolsSite.sh [websiteName] [userName]
#   ./createToolsSite.sh trunk skapadia
#

    echo "----------------------------------" 1>&2
    echo "   Starting site setup " 1>&2
    echo "----------------------------------" 1>&2   

    # Confirm that they passed in a website name. 
    if [ -z "$1" ]; then
        echo "You must enter a website name to use." 1>&2
        exit 1
    fi

    # Confirm that they passed in a username for the site they want to create. 
    if [ -z "$2" ]; then
        echo "You must enter a username." 1>&2
        exit 1
    fi

    # make sure the username entered exits on the system.
    if [ ! -d "/home/$2" ]; then
        echo "The username is not a valid user on this site." 1>&2
        echo "Please add him as a user first." 1>&2
        exit 1
    fi

    if [ ! -f configuration.cfg ]; then
       echo "The configuration file is not present." 1>&2
       exit 1
    fi

    # load configuration file
    source configuration.cfg

    USER=$2

    #define script variables start:
        WEBSITEDIRECTORY=/home/$USER/$USER_SITES_DIRECTORY/$1
        WEBSITEPATH=$WEBSITEDIRECTORY/spt

        #apache virtual host file name
        VHOST_SITE_NAME=$USER-$1.$SERVER_WEB_NAME   

        # Get the ip address of this box. 
        #IPADDRESS=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
        IPADDRESS="127.0.0.1"
        
        SITELOCATION=$WEBSITEPATH/public
        LOGLOCATION=/home/$USER/logs

    #define script variables done

    if [ -d "$WEBSITEPATH" ]; then
        echo "That website already exits."  1>&2
        exit 1    
    fi

    if [ -f /etc/apache2/sites-available/$VHOST_SITE_NAME ]; then
       echo "A website already exists under this name." 1>&2
       exit 1
    fi
    
    # make log directory if it's not present. 
    if [ -d "$LOGLOCATION" ]; then
        echo "----------------------------------" 1>&2
        echo "   making log directory: $LOGLOCATION " 1>&2
        echo "----------------------------------" 1>&2   
            mkdir -p $LOGLOCATION        
            chown $USER:$USER $LOGLOCATION 
    fi
    
    # touch the files and give write global write permissions.
        touch $LOGLOCATION/access.log
        touch $LOGLOCATION/error.log
        touch $LOGLOCATION/messages.log

        chmod 777 $LOGLOCATION/access.log
        chmod 777 $LOGLOCATION/error.log
        chmod 777 $LOGLOCATION/CPF_messages.log


    # make sym link to php_error.log 
    ln -s $PHP_ERROR_LOG_FILE $LOGLOCATION/php_errors.log

    echo "----------------------------------" 1>&2
    echo "   Making website path: $WEBSITEPATH " 1>&2
    echo "----------------------------------" 1>&2   
        # create the website directory
        mkdir -p $WEBSITEPATH
        chown $USER:$USER $WEBSITEDIRECTORY 

    echo "----------------------------------" 1>&2
    echo "   Making subversion folder, touching file and placing content" 1>&2
    echo "----------------------------------" 1>&2   
        # make a subversion folder and store a key value pair so auth 
        # doesn't prompt for it when checking out.         
        mkdir /root/.subversion/        
        touch /root/.subversion/servers
        echo "[global]" >> /root/.subversion/servers
        echo "# Password / passphrase caching parameters:" >> /root/.subversion/servers
        echo "store-passwords = no" >> /root/.subversion/servers
        echo "store-plaintext-passwords = no" >> /root/.subversion/servers

    echo "----------------------------------" 1>&2
    echo "   Performing an svn co of site. please wait ... " 1>&2
    echo "----------------------------------" 1>&2       
        # check out the site    
        svn co --quiet --username $SVNUSER --password $SVNPASS http://svn.cleanpowerfinance.com/spt/trunk $WEBSITEPATH


    echo "----------------------------------" 1>&2
    echo "   Giving permissions to folders" 1>&2
    echo "----------------------------------" 1>&2   
        # confirm svn co worked.    
        if [ ! -d "$WEBSITEPATH/application/Models/Proxies" ]; then
            echo "svn co did not work correctly..."  1>&2
            exit 1    
        fi        

        # setup permission
        chmod -R 777 $WEBSITEPATH/application/Models/Proxies
        chmod -R 777 $SITELOCATION/logos
        chmod -R 777 $WEBSITEPATH/library/CPF/Formset/form_definitions
        chmod -R 777 $WEBSITEPATH/temp_workspace
        chmod -R 777 $SITELOCATION/uploads/ 
        chmod -R 777 $SITELOCATION/downloads/

        chmod 0777 $SITELOCATION/form_rendered 
        chmod 0777 $WEBSITEPATH/library/CPF/Formset/FDF_files


    echo "----------------------------------" 1>&2
    echo "   Create a local version of the run_zf_script.sh script " 1>&2
    echo "----------------------------------" 1>&2   
        cp $WEBSITEPATH/cron/run_zf_script.sh.template $WEBSITEPATH/cron/run_zf_script.sh




    echo "----------------------------------" 1>&2
    echo "   Making sym links in the library folder. " 1>&2
    echo "----------------------------------" 1>&2   
        # create sym links
        ln -s $ZEND_PATH $WEBSITEPATH/library/Zend
        ln -s $DOCTRINE_PATH $WEBSITEPATH/library/Doctrine

    echo "----------------------------------" 1>&2
    echo "   Grabbing vhost file. " 1>&2
    echo "----------------------------------" 1>&2   
        # Copy sample Apache's virtual host file over to this machine.
        wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/conf/apache/virtualhostfile

    echo "----------------------------------" 1>&2
    echo "   Calling sed to do string replacements. " 1>&2
    echo "----------------------------------" 1>&2   
        # string replacement of variables.         
        sed -i "s|HOST_NAME_GOES_HERE|$VHOST_SITE_NAME|g" virtualhostfile
        sed -i "s|HOST_NAME_ALIAS_GOES_HERE|$IPADDRESS|g"  virtualhostfile
        sed -i "s|APPLICATION_ENV_GOES_HERE|$APPLICATION_ENV|g"  virtualhostfile
        sed -i "s|SITE_DOCUMENT_ROOT|$SITELOCATION|g"  virtualhostfile
        sed -i "s|SITE_LOCATION|$SITELOCATION|g"  virtualhostfile
        sed -i "s|LOG_FILE_LOCATION|$LOGLOCATION|g"  virtualhostfile

        mv /tmp/virtualhostfile /etc/apache2/sites-available/$VHOST_SITE_NAME

    echo "----------------------------------" 1>&2
    echo "   Enabling site. " 1>&2
    echo "----------------------------------" 1>&2   
        # Enable the new virtual site. 
        a2ensite $VHOST_SITE_NAME

    echo "----------------------------------" 1>&2
    echo "   Forcing apache to reload config information. " 1>&2
    echo "----------------------------------" 1>&2   
        # Reload apache settings:
        service apache2 reload

    echo "----------------------------------" 1>&2
    echo "   Clean up. " 1>&2
    echo "----------------------------------" 1>&2   
        # cleaning up and removing svn authinfo
        rm -rf ~/.subversion

        # give ownership of the new website to the user created.    
        chown $USER:$USER -R $WEBSITEPATH 

    echo "----------------------------------" 1>&2
    echo "   Site setup is complete." 1>&2
    echo "----------------------------------" 1>&2   
