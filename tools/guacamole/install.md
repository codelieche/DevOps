## Guacamole安装

> 操作系统：CentOS7

### 安装jdk与Tomcate

- 安装jdk11：`yum install java-11-openjdk`

- 安装[Tomcat9](https://tomcat.apache.org/download-90.cgi)：

  - `wget http://apache.website-solution.net/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz`
  - `tar zxvf apache-tomcat-9.0.16.tar.gz`
  - 启动Tomcat：`cd apache-tomcat-9.0.16 && ./bin/startup.sh`
  - 停止Tomcat：`./bin/shutdown.sh`

  ```
  [root@localhost apache-tomcat-9.0.16]# ./bin/startup.sh
  Using CATALINA_BASE:   /root/download/apache-tomcat-9.0.16
  Using CATALINA_HOME:   /root/download/apache-tomcat-9.0.16
  Using CATALINA_TMPDIR: /root/download/apache-tomcat-9.0.16/temp
  Using JRE_HOME:        /usr
  Using CLASSPATH:       /root/download/apache-tomcat-9.0.16/bin/bootstrap.jar:/root/download/apache-tomcat-9.0.16/bin/tomcat-juli.jar
  Tomcat started.
  ```

- 防火墙开放端口：`iptables -I INPUT -p tcp --dport 8080 -j ACCEPT`

### 安装Guacamole Server

#### 安装依赖包

- Required Dependencies

```bash
# 安装Cairo
yum install -y cairo cairo-devel

# 安装libjpeg-turbo 
# yum install -y libjpeg-turbo libjpeg62-turbo-dev
#cd /etc/yum.repos.d/
#wget https://libjpeg-turbo.org/pmwiki/uploads/Downloads/libjpeg-turbo.repo
#yum install -y libjpeg-turbo-official
yum install -y libjpeg-devel

# 安装libpng
yum install -y libpng libpng-devel
# 安装OSSP UUID
yum install -y uuid uuid-devel
```

- Optional Dependencies

```bash
# 安装FFmpeg
yum install -y ffmpeg ffmpeg-devel
# 安装FreeRDP
yum install -y freerdp freerdp-devel
# 安装Pango
yum install -y pango pango-devel
# 安装libssh2
yum install -y libssh2 libssh2-devel
# 安装libtelnet
yum install -y libtelnet libtelnet-devel
# 安装libVNCServer
yum install -y libvncserver libvncserver-devel
# 安装PulseAudio
yum install -y pulseaudio pulseaudio-libs-devel
# 安装OpenSSL
yum install -y openssl openssl-devel
# 安装libvorbis
yum install -y libvorbis libvorbis-devel
# 安装libwebp
yum install -y libwebp libwebp-devel
```

#### 编译安装guacamole server源码

- 先安装gcc：`yum install gcc`

```bash
cd ~/download
# 下载源码：http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.0.0/source/guacamole-server-1.0.0.tar.gz
# 解压源码
tar zxvf guacamole-server-1.0.0.tar.gz
# 进入解压目录
cd guacamole-server-1.0.0

# 可能报错：就安装下libtool
# autoreconf: failed to run libtoolize: No such file or directory
# yum install libtool

autoreconf -fi
# 执行config: 将guacd的启动脚本放置在/etc/init.d
./configure --with-init-dir=/etc/init.d
# 编译
make && make install
# 更新已安装库的系统缓存
ldconfig
```

### 安装Guancamole Client

- 安装maven: `yum install maven`

```bash
# 下载源码
git clone git://github.com/apache/guacamole-client.git
# 进入目录
cd guacamole-client
# build guancamole-client
mvn package
```

- 遇到的问题：Unable to load the mojo 'test'

  > 下载最新的maven:
  >
  > wget http://apache.01link.hk/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
  >
  > tar zxvf apache-maven-*.tar.gz
  >
  > /root/download/apache-maven-3.6.0/bin/mvn package

- 把war包复制到Tomcat的webapps目录下

  ```bash
  cp guacamole/target/guacamole-1.1.0.war ../apache-tomcat-9.0.16/webapps/guacamole.war
  ```

### 配置

```bash
# 创建路径
mkdir /etc/guacamole
touch /etc/guacamole/guacamole.properties
touch /etc/guacamole/user-mapping.xml

echo "export GUACAMOLE_HOME=/etc/guacamole" >> /etc/profile
source /etc/profile
```

- User-mapping.xml

```xml
<user-mapping>
<authorize username="admin"
  password="319f4d26e3c536b5dd871bb2c52e3178"
  encoding="md5">
    <connection name="192.168.6.116">
        <protocol>ssh</protocol>
        <param name="hostname">192.168.6.116</param>
        <param name="port">22</param>
        <param name="username">jumpserver</param>
    </connection>


    <connection name="localhost">
        <protocol>ssh</protocol>
        <param name="hostname">localhost</param>
        <param name="port">22</param>
        <param name="username">root</param>
        <param name="password">abcdefg</param>
    </connection>

</authorize>
</user-mapping>
```

密码是:PASSWORD采用md5加密。

- 重启Tomcat和Guacamole
- 访问系统：`http://192.168.6.118:8080/guacamole/`

#### Database Authentication

- /etc/guacamole/guacamole.properties

```
# MySQL Connect
mysql-hostname: 192.168.6.1
mysql-port: 3307
mysql-database: guacamole_develop
mysql-username: guacamole
mysql-password: guacamole_db_password
```

- 下载`guacamole-auth-jdbc-mysql-1.0.0.jar`到/etc/guacamole/extensions

  `wget http://apache.mirrors.tds.net/guacamole/1.0.0/binary/guacamole-auth-jdbc-1.0.0.tar.gz`

- 下载`mysql-connector-java-5.1.46.jar`到**/etc/guacamole/lib**

  `wget https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz`

  解压把相关jar包移动到相应的目录。

  ```bash
  [root@localhost guacamole]# tree /etc/guacamole/
  /etc/guacamole/
  ├── extensions
  │   ├── guacamole-auth-jdbc-mysql-1.0.0.jar
  │   └── mysql-connector-java-5.1.46.jar
  ├── guacamole.properties
  ├── lib
  │   └── mysql-connector-java-5.1.46.jar
  └── user-mapping.xml
  ```

- 导入sql文件：`001-create-schema.sql`, `002-create-admin-user.sql`

```bash
➜  tree guacamole-auth-jdbc-1.0.0/mysql/schema
guacamole-auth-jdbc-1.0.0/mysql/schema
├── 001-create-schema.sql
├── 002-create-admin-user.sql
```



**默认的管理员账号和密码是**：`guacadmin`

### 遇到的问题

- 中文乱码

  - `fc-list`查看字体
  - `yum install -y fontconfig`
  - 下载字体到：/usr/share/fonts/chinese (记得先创建目录)
  - 安装ttmkfdir: `yum install -y ttmkfdir`
  - 执行命令：`ttmkfdir -e /usr/share/X11/fonts/encodings/encodings.dir`
  - 编辑文件：`/etc/fonts/fonts.conf`加入`<dir>/usr/share/fonts/chinese</dir>`

  ```xml
  <dir>/usr/share/fonts</dir>
  <dir>/usr/share/X11/fonts/Type1</dir> <dir>/usr/share/X11/fonts/TTF</dir> <dir>/usr/local/share/fonts</dir>
  <dir>/usr/share/fonts/chinese</dir>
  <dir prefix="xdg">fonts</dir>
  ```

  - 再次连接web服务器，中文就不乱码了

- 英文字符，有些上浮了
  - 解决方式：` yum install dejavu-sans-mono-fonts.noarch`
  - 退出，重新进入，就OK了。