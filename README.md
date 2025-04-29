# My project
This is a small project by having a Docker image that contains 3 Django web apps and a webserver composed of an nginx + gUnicorn instance.

This should be the folder structure:

```
project/
├── .venv
├── api/
│   └── manage.py, api/, etc.
├── public_site/
│   └── manage.py, public_site/, etc.
├── private_site/
│   └── manage.py, private_site/, etc.
├── nginx.conf
├── requirements.txt
├── Dockerfile
└── start.sh
```

## Step 1: Create the folder structure and the needed files
### Requirements file

Create a file called *requirements.txt* and put the following code there:
```
Django>=3.2
gunicorn
```

### Create + activate virtual environment + install requirements
```
$ python -m venv .venv
$ source .venv/bin/activate
$ pip install -r requirements.txt
```

### API
Create the **api** Django application
```
$ mkdir api
$ django-admin startproject api ./api
```

### Public website
Create the **public_site** Django application
```
$ mkdir public_site
$ django-admin startproject public_site ./public_site
```

Create the **private_site** Django application
```
$ mkdir private_site
$ django-admin startproject private_site ./private_site
```

## Step 2: Configure Nginx + Startup Script + Docker image
### Nginx configuration file
Create a file called *nginx.conf* and put the following code there:
```
http {
    server {
        listen 80;

        location /api/ {
            proxy_pass http://127.0.0.1:8001/;
        }
        location /private/ {
            proxy_pass http://127.0.0.1:8003/;
        }
        location / {
            proxy_pass http://127.0.0.1:8002/;
        }
    }
}
```



### Startup script
Create a file called *start.sh* and put the following code there:
```
#!/bin/bash
set -e

# Run Gunicorn for each Django project
gunicorn --chdir api api.wsgi:application --bind 127.0.0.1:8001 & 
gunicorn --chdir public_site public_site.wsgi:application --bind 127.0.0.1:8002 & 
gunicorn --chdir private_site private_site.wsgi:application --bind 127.0.0.1:8003 & 

# Start nginx in foreground
nginx -g 'daemon off;'
```

After creating the file, change its permissions to be executable:
```
$ chmod +x start.sh
```

### Docker image + docker start commands
On the *Dockerfile*, put the following code:
```
FROM python:3.9-slim

# Install nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

RUN rm /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /app/start.sh

EXPOSE 80

CMD ["/app/start.sh"]

```


# Step 3: Build and run
On the shell, run the following command to build the image:
```
docker build -t my-website .
```

On the shell, run the following command to run the image:
```
docker run -p 80:80 my-website
```