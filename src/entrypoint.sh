#!/bin/bash
set -e

echo "<?php
defined('BASEPATH') OR exit('No direct script access allowed');
\$host = '${DB_HOST}';
\$databaseuser = '${DB_USERNAME}';
\$databasename = '${DB_DATABASE}';
\$dbpassword = '${DB_PASSWORD}';
define('DB_SERVER', \$host);
define('DB_USERNAME', \$databaseuser);
define('DB_PASSWORD', \$dbpassword);
define('DB_DATABASE', \$databasename);
?>" > /var/www/html/config.php

exec "$@"

cp -f index1.php index.php