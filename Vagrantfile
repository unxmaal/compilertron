
#####
# Change these settings to match your environment
#####

gcc_repo =          "https://github.com/onre/gcc.git"
gcc_repo_branch =   "gcc-4_7-irix"
irix_root =         "http://mirror.larbob.org/compilertron/irix-root.6.5.30.tar.bz2"

Target_Base_Box =   "debian/contrib-jessie64"
Target_Version =    "8.11.0"
RAM_for_VM =        "8016"
NUM_of_CPUs =       "4"


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

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "ansible/compilertron_setup.yml"
    ansible.extra_vars = {
        gcc_repo: gcc_repo,
        gcc_repo_branch: gcc_repo_branch,
        irix_root: irix_root
    }
  end
end