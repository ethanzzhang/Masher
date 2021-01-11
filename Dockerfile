FROM ubuntu:18.04


# 安装git、python、nginx、supervisor、redis、mongodb等，并清理缓存
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:jonathonf/python-3.6 -y && \
    apt-get update && \
    apt-get install -y git python3.6 python3-pip nginx vim supervisor mongodb libsm6 libxrender1 libxext-dev ffmpeg redis-server && \
    pip3 install --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple pip setuptools && \
    rm -rf /var/lib/apt/lists/* && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    mkdir /home/EDA_SERVER && \
    mkdir -p /data/db


# nginx、supervisor、时区配置
COPY nginx-app.conf /etc/nginx/sites-available/default
COPY supervisor-app.conf /etc/supervisor/conf.d/
COPY localtime /etc/localtime
COPY supervisord.conf /etc/supervisor/supervisord.conf

# 安装项目所需python第三方库及将项目拷贝进镜像中
COPY EDA_SERVER  /home/EDA_SERVER
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r /home/EDA_SERVER/requirements.txt && \
    cd /home/EDA_SERVER && \
    python3 manage.py makemigrations inquest server && \
    python3 manage.py migrate


EXPOSE 80
CMD ["supervisord", "-n"]
