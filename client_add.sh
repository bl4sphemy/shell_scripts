#!/bin/bash
#Author: Brian Rawlins 11/14/2017
#Add new clinet to nginx LB. 

CLIENT=$1
TEMPLATE=/etc/nginx/sites-available/template.example.com.conf
TEMPLATE_SITE=template.example.com
AVAILABLE=/etc/nginx/sites-available
ENABLED=/etc/nginx/sites-enabled

[ $# -eq 0 ] && { echo "Usage: $0 client_name"; exit 1;}

#make sure client isnt already enabled...
if [ -e $ENABLED/$CLIENT.conf ]
  then
	echo "Whoa there, looks like this client is already enabled."
	echo
	exit 1
fi

#make sure nginx is sane first...
echo
if `nginx -t`
  then
	echo "Proceeding...this script will create a new client"
	echo "vhost from a pre-existing template."
	echo
  else
	echo "Uh oh, it looks like a pre-existing nginx issue"
	echo "will prevent us from moving forword..."
	echo "be an ssl crt error and nginx complaining."
	echo
	echo "Something is wrong, check output of 'nginx -t',"
	echo "and try again. The most common issue will likely"
	echo "be an ssl crt error and nginx complaining."
	exit 1
fi

#cp template
echo "Adding $CLIENT.conf to nginx..."

cp $TEMPLATE $AVAILABLE/$CLIENT.conf
sed -i "s/${TEMPLATE_SITE}/${CLIENT}/g" $AVAILABLE/$CLIENT.conf
ln -s $AVAILABLE/$CLIENT.conf $ENABLED

echo

if `nginx -t`
  then
	echo "Everything looks good!"
	echo "If you are confident everything is correct,"
	echo "simply 'service nginx reload'"
	echo
  else
	echo "Something is wrong, check output of 'nginx -t',"
	echo "and try again. The most common issue will likely"
	echo "be an ssl crt error and nginx complaining."
	echo
	exit 1
fi
