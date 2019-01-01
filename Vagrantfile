
#####
# Change these settings to match your environment
#####

gcc_zip =           "https://github.com/onre/gcc/archive/gcc-4_7-irix.zip"
irix_root =         "http://mirror.larbob.org/compilertron/irix-root.6.5.30.tar.bz2"
binutils =          "https://mirrors.tripadvisor.com/gnu/binutils/binutils-2.17a.tar.bz2"

Target_Base_Box =   "debian/contrib-stretch64"
Target_Version =    "9.6.0"
RAM_for_VM =        "2048"
NUM_of_CPUs =       "2"


##### 
# Optional Settings - leave blank if not used
#####

# If you have a NFS server setup you can set it up here to be mounted to quickly
# move files to the SGI.
# Set use_nfs to true and put in the host/share and the path where you want it mounted
# on the VM

use_nfs =         true
nfs_host =        "192.168.251.10:/files"
nfs_path =        "files"


##### 
# end of settings
#####

current_dir = File.dirname(File.expand_path(__FILE__))     
disk_prefix = 'compiledisk'
disk_ext ='.vdi'      
compiledisk = "%s/%s%s" % [current_dir,disk_prefix,disk_ext] 

#
# Main configure block
Vagrant.configure("2") do |config|
  config.vm.box =               Target_Base_Box
  config.vm.box_version =       Target_Version
  config.vm.post_up_message =   [ "compilertron configuration stage" ]
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

 # setup VirtualBox Settings
  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.memory = RAM_for_VM
    v.cpus = NUM_of_CPUs
  end

  # Create disk for compiled objects
  config.vm.provider "virtualbox" do |v|
    unless File.exist?(compiledisk)
      v.customize ['createhd', '--filename', compiledisk, '--size', 50 * 1024]
    end
      v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', compiledisk]
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
          gcc_zip: gcc_zip,
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
          gcc_zip: gcc_zip,
          irix_root: irix_root,
          binutils: binutils,
          use_nfs: use_nfs,
          nfs_host: nfs_host,
          nfs_path: nfs_path
      }
    end
  end
end