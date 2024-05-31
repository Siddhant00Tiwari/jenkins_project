# Freestyle Jenkins CI/CD
In this project, we will make freestyle ***Jenkins*** pipeline with ***Ansible*** automation.

### Technologies included:

1. **GitHub**: Source code repository
2. **Jenkins**: Continuous integration server
3. **Ansible**: Automation tool
4. **Docker**: Container tool
5. **Docker Hub**: Container image registry

### Prerequisites

- A repository containing our website. In my case https://github.com/Siddhant00Tiwari/Static-website.git.
- A repository hosting our Dockerfile, which in my case is this very repo.
- A docker hub registry to store our built images.
- Three AWS instances*(Amazon linux 2 in this case)*,  i.e Jenkins host, Ansible host and Docker host. And allow port 8080 in the security group.
    
    ![intances.png](https://github.com/Siddhant00Tiwari/jenkins_project/blob/e2aef9245b79420a28f9bdc8d92bdffd3ea68cbd/images/intances.png)
    

## Setting up our instances

### Jenkins Host

1. Set up the hostname using : `sudo hostname set-hostname jenkins-host` and the root password.
2. Import Jenkins repo using : `sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo`
3. Import Jenkins gpg key using: 
`sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key` 
4. Install Java JDK using : 
`yum install fontconfig java-17-openjdk`
5. Install Jenkins using : `yum install jenkins`
6. Upgrade packages : `yum upgrade` 
7. Install git : `yum install git`
8. Enable and start Jenkins and git using : `systemctl enable --now jenkins.service ; systemctl enable --now git`
9. Give permission for root SSH login and password login in `/etc/ssh/sshd_config` and restart the sshd service using `systemctl restart sshd`
10. Generate SSH key and send it to the Ansible-Host using : `ssh-keygen` and `ssh-copy-id root@{ansible_host_ip}`

> *The Jenkins browser configuration will be done in later stage.*
> 

### Ansible Host

1. Set up the hostname using : `sudo hostname set-hostname ansible-host` and the root password.
2. Install Ansible package (! for amazon linux 2 instance we need to add EPEL repository)        `sudo amazon-linux-extras install epel -y`  and then install Ansible using :                         `sudo yum install -y ansible`
3. Start and enable Ansible : `systemctl enable --now ansible`
4. Install docker : `yum install docker`
5. Start and enable docker: `systemctl enable --now docker`
6. Login to you Docker Hub account: `docker login`(so that we can push the image we’ll build and label here onto our dockerhub registry)
7. Open the file `/etc/ansible/hosts` and enter the Docker host IP 
    
    ![ansible hosts file.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/eee4c64e-e974-4351-83df-68c55819dabb/ansible_hosts_file.png)
    
8. Then write an ansible playbook in `/root/playbooks/docker.yaml`
    
    ![ansible playbook.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/f509144c-ac28-4ee9-a8cf-02aa0b6b740a/ansible_playbook.png)
    
    In this playbook, first we are stopping the already running container(while will be the case when it’s in production environment). Then we will remove the container and remove the image from our docker host. Then we will run a new container with the same name but from the new version of the image that we will upload on our Docker Hub registry. 
    
9. Give permission for root SSH login and password login in `/etc/ssh/sshd_config` and restart the sshd service using `systemctl restart sshd`
10. Generate SSH key and send it to the Docker-Host using :                                                         `ssh-keygen` and `ssh-copy-id root@{docker_host_ip}`

### Docker Host

1. Set up the hostname using : `sudo hostname set-hostname docker-host` and the root password.
2. Install docker : `yum install docker`
3. Start and enable docker: `systemctl enable --now docker`
4. Give permission for root SSH login and password login in `/etc/ssh/sshd_config` and restart the sshd service using `systemctl restart sshd`

### Jenkins Browser setup

1. Access jenkins through browser `https://jenkins_server_ip:8080`
2. Unlock jenkins, the initial jenkins password is stored in `/var/lib/jenkins/secrets/intialAdminPassword`
    
    ![unlock jenkins.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/607f9472-d8e4-4297-bd32-935e29c5c5f1/unlock_jenkins.png)
    
3. Select Install Suggested plugins.
    
    ![install suggested plugins.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/1b4f4d79-cdb8-41be-a0a6-30dedfcc001d/install_suggested_plugins.png)
    
4. Create User ID and Password
    
    ![username page.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/e06a10e1-5868-48f3-a6d0-9b20ffd86565/username_page.png)
    
5. When reaching Dashboard, go to Manage Jenkins and go to plugins and search in Available plugins “Publish over ssh”
    
    ![ssh plugin.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/0ae5d221-06fc-41ea-95e3-b13fd7f17131/ssh_plugin.png)
    
6. Then in Manage Jenkins, go to System and scroll down to ssh server and add the Ansible server and Jenkins server and it’s root password. Save it and return to dashboard.
    
    ![jenkins ssh.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/45737873-41a7-408c-aeda-50626eee0c4c/jenkins_ssh.png)
    
    ![ansible ssh.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/1925c7ad-e634-4dd7-988b-521967b5c906/ansible_ssh.png)
    
7. From Dashboard go to Add an Item and add a freestyle project and name it “Jenkins-project”.
    
    ![add an item.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/f02bce6d-4e37-435c-87a9-4ec0ebdd368c/add_an_item.png)
    
8. In Jenkins-project, go to Configuration and scroll down to source code management and add this git repository.
    
    ![git repo entry.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/a44f5f53-964a-4e61-b3b2-7a280a383024/git_repo_entry.png)
    
9. Then scroll down to Build steps and select “Send files or execute commands over SSH” and then add Jenkins in ssh server and in exec command put `rsync -avh /var/lib/jenkins/workspace/jenkins-project/Dockerfile root@{anisble_ip}:/opt` , this command copies Dockerfile from jenkins file and paste it in the `/opt` directory of the ansible host server.
    
    ![jenkins ssh command.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/e257da7a-e367-4b2d-9901-59b23c75f368/jenkins_ssh_command.png)
    
10. Then scroll down and add another Build steps and select “Send files or execute commands over SSH” and then add ansible server and in exec command put:
    
    ![ansible ssh commands.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/c8d2ad79-ae9a-4347-a58d-83e822b81d9d/ansible_ssh_commands.png)
    
    1. `cd /opt`change the directory to /opt.
    2. `docker image build -t $JOB_NAME:$BUILD_ID .` build an image from the Dockerfile that has been copied by the jenkins server.
    3. `docker image tag $JOB_NAME:$BUILD_ID {docker_hub_account}/$JOB_NAME:$BUILD_ID` then give the image a tag that is in reference to the docker hub registry.
    4. `docker image tag $JOB_NAME:$BUILD_ID {docker_hub_account}/$JOB_NAME:latest` adding an additional tag “latest” so we don’t have to define a new tag every time in the Ansible Playbook.
    5. `docker image push {docker_hub_account}/$JOB_NAME:$BUILD_ID` push the image on you docker hub account.
    6. `docker image push {docker_hub_account}/$JOB_NAME:latest` add a new tag “latest” to the latest image.
    7. `docker image rmi $JOB_NAME:$BUILD_ID` remove the image from the ansible server so that a new image can be created.
    8. `docker image rmi {docker_hub_account}/$JOB_NAME:$BUILD_ID` remove all the tags related to the image.
    9. `docker image rmi {docker_hub_account}/$JOB_NAME:latest` remove the image with the latest tag.
11. Then add Post Build step, select “Send build over SSH” and add ansible server and in Exec command add `ansible-playbook /root/playbooks/docker.yaml` this executes the playbook we have stored in `/root/playbooks` 
12. Apply and save
13. Then in Jenkins-project, hit build now.
    
    ![build now.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/40cb6d83-012d-4c42-91d8-618cce6ecc6a/build_now.png)
    
    We see that our build was successful and our container is created.
    
14. In our docker hub account we can find the image with latest tag.
    
    ![image uploaded.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/3fe9ca59-f57c-4d05-a191-62710c31037c/image_uploaded.png)
    
15. And our website is hosted.
    
    ![website.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/77ead240-a866-4aa1-883b-179fa59f3972/4befa3f4-a01f-4d0d-9225-44dd8698c532/website.png)
