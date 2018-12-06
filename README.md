# seminar: Dec 06
Demo project used for seminar
=============================
($ git clone https://github.com/scmlearningcentre/seminar.git seminar)
I) Provision Server
  1. Create Linux containers based on Ubuntu 
     $ docker run -it ubuntu /bin/bash
  2. Create AWS-EC2 instances using Ansible playbooks
     $ cd playbooks
     $ ansible-playbook aws.yml --tags ec2
II) Configure the environment needed
   $ ansible-playbook setup.yml
III) Build the project using Maven inside a container
   $ docker run -it --rm --name mymvn -v "$PWD":/usr/src/mymaven -w /usr/src/mymaven maven:3.2-jdk-7 mvn package
IV) Build your own Image
   $ docker build -t myprod .
   - Test the Image
     $ docker run --name myjboss -d -p 9990:9990 -p 8080:8080 myprod
       (Access war using http://<hostmachine>:8080/samplewar/)
V) Setup CI using Jenkins
VI) Upload artifacts to AWS S3
