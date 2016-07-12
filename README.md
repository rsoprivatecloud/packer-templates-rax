README
======

Get a Build Host
----------------

If you already have a Linux workstation or access to a Linux server with hardware virtualization support, you can use that.

Or, if you have access to any OpenStack environment and have it configured to passthrough the hardware virtualization flags to the OpenStack Instance, you can create an OpenStack Instance from any modern Ubuntu or CentOS cloud image.

The following instructions will focus on using a CentOS 7 based workstation/server/instance as the build host.

Setup the Build Host
--------------------

Install QEMU:

    yum install qemu-kvm unzip git

Packer needs __qemu-kvm__ available in the BASH path. For some reason it isn't added. Add it:

    echo 'export PATH=$PATH:/usr/libexec' > /etc/profile.d/libexec-path.sh

Download the [latest version of Packer](https://www.packer.io/downloads.html).

At the time of writing, Packer 0.10.1 is the latest. Download it using `curl`:

    curl -O https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip

Build an Image with Packer
--------------------------

Download the __packer-templates-rax__ repository:

    git clone https://github.com/rsoprivatecloud/packer-templates-rax.git

Change into the appropriate directory:

    cd packer-templates-rax

Finally, run `packer`:

    packer build template-centos-7-x86_64-1511-rax-openstack.json

After about 10 minutes, the image will be created.

Prepare the Image for Upload
----------------------------

The resulting image is larger than it needs to be. It can be compressed and the current size reduced by half.

Change into the appropriate directory:

    cd output-centos-7-x86_64-1511-rax

Compress the image:

    qemu-img convert -c centos-7-x86_64-1511-rax -O qcow2 centos-7-x86_64-1511-rax.qcow2

Upload the Image to Glance
--------------------------

If you don't already have the `glance` command available, you will need to install it.

### Install python-glanceclient and Its Dpendencies

Install the necessary packages:

    yum install gcc python-pip python-devel

Install pip:

    easy_install pip

Install the necessary Python depedences:

    pip install netifaces

Instsall python-glanceclient:

    pip install python-glanceclient

### Obtain an openrc File

Download an openrc file from your OpenStack environment associated with the OpenStack Project you want the Glance Image to be available in.

You could also make the Glance Image Public within OpenStack so every OpenStack Project can see it.

### Upload the Image to Glance

Source the openrc file:

    source /root/openrc

Upload the image to Glance with the following command:

    glance image-create --name centos-7-x86_64-1511-rax --disk-format=qcow2 --container-format=bare --file centos-7-x86_64-1511-rax.qcow2

You should now be able to create OpenStack Instances from the new Glance Image.

References
----------

[packer-openstack-centos-image](https://github.com/jkhelil/packer-openstack-centos-image)

[Packer Image Builder for RHEL Family (RedHat, CentOS, Oracle Linux)](https://github.com/TelekomLabs/packer-rhel)