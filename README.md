README
======

Get a Build Host
----------------

If you already have a Linux workstation or access to a Linux server with hardware virtualization support, you can use that.

Or, if you have access to any OpenStack environment and have it configured to passthrough the hardware virtualization flags to the OpenStack Instance, you can create an OpenStack Instance from any modern Ubuntu or CentOS cloud image.

The following instructions will focus on using a CentOS 7 based workstation/server/instance as the build host and will result in creating two CentOS 7 OpenStack compatible images: an XFS image and a ext4 image.

Setup the Build Host
--------------------

Install QEMU:

    yum install qemu-kvm unzip git

Packer needs __qemu-kvm__ available in the BASH path. For some reason it isn't added. Add it:

    echo 'export PATH=$PATH:/usr/libexec' > /etc/profile.d/libexec-path.sh

Also, add __/usr/local/bin__ to your BASH path:

    echo 'export PATH=$PATH:/usr/local/bin' > /etc/profile.d/usr-local-bin-path.sh

You might need to log out and log back into the root user for the BASH path changes to take affect.

Download the [latest version of Packer](https://www.packer.io/downloads.html).

At the time of writing, Packer 0.10.1 is the latest. Download it using `curl`:

    curl -O https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip

Unzip __packer__:

    unzip packer_0.10.1_linux_amd64.zip

There's already a program named __packer__ in the BASH path. Rename the __packer__ you just downloaded to __packerio__:

    mv /root/packer /root/packerio

Move the newly renamed __packerio__ binary to __/usr/local/bin__:

    mv /root/packerio /usr/local/bin

Build an Image with Packer
--------------------------

Download the __packer-templates-rax__ repository:

    git clone https://github.com/rsoprivatecloud/packer-templates-rax.git

Change into the appropriate directory:

    cd packer-templates-rax

Finally, run `packer`:

    packerio build template-centos-7-x86_64-1511-rax-openstack.json

After about 10 minutes, the images will be created.

Prepare the Image for Upload
----------------------------

The resulting image is larger than it needs to be. It can be compressed and the current size reduced by half.

### XFS Image

Change into the appropriate directory:

    cd output-centos-7-x86_64-1511-rax-xfs

Compress the image:

    qemu-img convert -c centos-7-x86_64-1511-rax-xfs -O qcow2 centos-7-x86_64-1511-rax-xfs.qcow2

### ext4 Image

Change into the appropriate directory:

    cd output-centos-7-x86_64-1511-rax-ext4

Compress the image:

    qemu-img convert -c centos-7-x86_64-1511-rax-ext4 -O qcow2 centos-7-x86_64-1511-rax-ext4.qcow2

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

### Upload the Images to Glance

Source the openrc file:

    source /root/openrc

Upload the XFS image to Glance with the following command:

    glance image-create --name centos-7-x86_64-1511-rax-xfs --disk-format=qcow2 --container-format=bare --file centos-7-x86_64-1511-rax-xfs.qcow2

Upload the ext4 image to Glance with the following command:

    glance image-create --name centos-7-x86_64-1511-rax-ext4 --disk-format=qcow2 --container-format=bare --file centos-7-x86_64-1511-rax-ext4.qcow2

You should now be able to create OpenStack Instances from the new Glance Images.

References
----------

[packer-openstack-centos-image](https://github.com/jkhelil/packer-openstack-centos-image)

[Packer Image Builder for RHEL Family (RedHat, CentOS, Oracle Linux)](https://github.com/TelekomLabs/packer-rhel)