APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:HsZi7OndrJnvGY4LgxoKom04i7LFcmiHJxXXDXisslA=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=${db_host}
DB_PORT=3306
DB_DATABASE=${db_name}
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}

BROADCAST_DRIVER=log
CACHE_DRIVER=file
SESSION_DRIVER=file
SESSION_LIFETIME=120
QUEUE_DRIVER=sync

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_DRIVER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

FILESYSTEM_DRIVER=s3
AWS_ACCESS_KEY_ID=${aws_access_key}
AWS_SECRET_ACCESS_KEY=${aws_secret_key}
AWS_DEFAULT_REGION=${aws_region}
AWS_BUCKET=${bucket_name}
AWS_URL=https://${cloudfront_domain_name}
