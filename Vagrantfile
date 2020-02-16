
#####
# Change these settings to match your environment
#####

sgug_rse =          "https://github-production-release-asset-2e65be.s3.amazonaws.com/232236744/b45be480-38a2-11ea-9052-76fadec4c942?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20200215%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20200215T152648Z&X-Amz-Expires=300&X-Amz-Signature=82e979b6d02b423851ac155fcbf06c9eb707237d6ce9a99d9e452f5be633889c&X-Amz-SignedHeaders=host&actor_id=1377410&response-content-disposition=attachment%3B%20filename%3Dsgug-rse-srpms-0.0.3alpha.tar.gz&response-content-type=application%2Foctet-stream"
irix_root =         "http://mirror.larbob.org/compilertron/irix-root.6.5.30.tar.bz2"
binutils =          "https://mirrors.tripadvisor.com/gnu/binutils/binutils-2.17a.tar.bz2"

Target_Base_Box =   "debian/buster64"
Target_Version =    "10.3.0"
RAM_for_VM =        "16048"
NUM_of_CPUs =       "8"


##### 
# Optional Settings - leave blank if not used
#####

# If you have a NFS server setup you can set it up here to be mounted to quickly
# move files to the SGI.
# Set use_nfs to true and put in the host/share and the path where you want it mounted
# on the VM

use_nfs =         false
nfs_host =        "192.168.251.10:/files"
nfs_path =        "files"


##### 
# end of settings
#####

current_dir = File.dirname(File.expand_path(__FILE__))     
disk_prefix = 'ctdisk'
disk_ext ='.vdi'      
ctdisk = "%s/%s%s" % [current_dir,disk_prefix,disk_ext] 

#
# Main configure block
Vagrant.configure("2") do |config|
  config.vm.box =               Target_Base_Box
  config.vm.box_version =       Target_Version
  config.vm.post_up_message =   [ "compilertron configuration stage" ]
  config.vm.synced_folder "./opt", "/opt", type: "virtualbox"

 # setup VirtualBox Settings
  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.memory = RAM_for_VM
    v.cpus = NUM_of_CPUs
  end

  # Create disk for compiled objects
  config.vm.provider "virtualbox" do |v|
    unless File.exist?(ctdisk)
      v.customize ['createhd', '--filename', ctdisk, '--size', 50 * 1024]
    end
      v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', ctdisk]
  end
end

#
# Provision the new box with Ansible plays
Vagrant.configure("2") do |config|
  if Vagrant::Util::Platform.windows?
   config.vm.provision :shell do |shell|
      shell.inline = "sudo apt-get -y install wget curl"
    end 
    config.vm.provision :guest_ansible do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "ansible/compilertron_setup.yml"
      ansible.extra_vars = {
          sgug_rse: sgug_rse,
          irix_root: irix_root,
          binutils: binutils,
          use_nfs: use_nfs,
          nfs_host: nfs_host,
          nfs_path: nfs_path
      }
    end
  else
    config.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "ansible/compilertron_setup.yml"
      ansible.extra_vars = {
          sgug_rse: sgug_rse,
          irix_root: irix_root,
          binutils: binutils,
          use_nfs: use_nfs,
          nfs_host: nfs_host,
          nfs_path: nfs_path
      }
    end
  end
end