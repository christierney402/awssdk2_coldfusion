#!/bin/bash
# Script to build an Amazon Linux 2 server and generate an AWS SDK2 example Java jar.
# The jar, as used by the examples, only works in Adobe ColdFusion 2021, not 2018.
# It should work in Lucee, but has not been tested.
# Use at your own risk. You may find interference, which is common in this scenereo.
# This shell script is meant to be run on a clean Amazon Linux 2 instance.
# Running this on an existing instance may result in unintended side-effects.
# result file is: ~/awssdk2/target/aws_sdk-2_17_112-1-jar-with-dependencies.jar
# This script has not been tested as a build script, but will run after logged in as a user

# Install OpenJDK 17 (AWS Corretto JDK)
sudo yum install java-17-amazon-corretto-devel

# Download Maven 3.8.4. Not using YUM, as that is a dated version (3.0.5).
# Other examples that add an Apache Maven repo, only go up to 3.5.
wget https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz -P /tmp

# Extract the archive in the /opt directory
sudo tar xf /tmp/apache-maven-3.8.4-bin.tar.gz -C /opt

# Delete temporary download
rm /tmp/apache-maven-3.8.4-bin.tar.gz

# To have more control over Maven versions and updates, we will create a symbolic link maven that will point to the Maven installation directory
# Note: To upgrade your Maven installation, simply unpack the newer version and change the symlink to point to it.
sudo ln -s /opt/apache-maven-3.8.4 /opt/maven

# Set up the environment variables
sudo bash -c 'cat <<EOF >/etc/profile.d/maven.sh
export JAVA_HOME=/usr/lib/jvm/jre-openjdk
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=\${M2_HOME}/bin:\${PATH}
EOF'
# Make the shell script executable
sudo chmod +x /etc/profile.d/maven.sh
# Add to the current evironment variables. Next reboot will call maven.sh and add them again.
source /etc/profile.d/maven.sh

# Create a Maven quickstart project:
cd ~
mvn -B archetype:generate  -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeVersion=1.4  -DgroupId=com.cfwebtools.awssdk2  -DartifactId=aws_sdk-2

# Add the Maven Project Object Model (POM)
# This includes your AWS service dependencies
cat <<EOF >~/awssdk2/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
 <modelVersion>4.0.0</modelVersion>
 <properties>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
 </properties>
 <groupId>com.example.myapp</groupId>
 <artifactId>aws_sdk-2_17_112</artifactId>
 <packaging>jar</packaging>
 <version>1.3</version>
 <name>awssdk217112</name>
 <dependencyManagement>
  <dependencies>
   <dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>bom</artifactId>
    <version>2.17.112</version>
    <type>pom</type>
    <scope>import</scope>
   </dependency>
  </dependencies>
 </dependencyManagement>
 <dependencies>
  <dependency>
   <groupId>junit</groupId>
   <artifactId>junit</artifactId>
   <version>4.13.2</version>
   <scope>test</scope>
  </dependency>
  <dependency>
   <groupId>software.amazon.awssdk</groupId>
   <artifactId>s3</artifactId>
  </dependency>
 </dependencies>
 <build>
  <plugins>
   <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.8.1</version>
    <configuration>
     <source>17</source>
     <target>17</target>
    </configuration>
   </plugin>
   <plugin>
    <artifactId>maven-assembly-plugin</artifactId>
    <executions>
     <execution>
      <phase>package</phase>
      <goals>
       <goal>single</goal>
      </goals>
     </execution>
    </executions>
    <configuration>
     <descriptorRefs>
      <descriptorRef>jar-with-dependencies</descriptorRef>
     </descriptorRefs>
    </configuration>
   </plugin>
  </plugins>
 </build>
</project>
EOF

# Create the .jar file with all dependencies
# If you change the artifact ID, run mvn clean install
cd ~/awssdk2
mvn package