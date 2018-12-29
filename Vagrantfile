
#####
# Change these settings to match your environment
#####
gcc_repo = "https://github.com/onre/gcc.git"

# FTP urls

##### 
# end of settings
#####

current_dir = File.dirname(File.expand_path(__FILE__))     
disk_prefix = 'compiledisk'
disk_ext ='.vdi'      
compiledisk = "%s/%s%s" % [current_dir,disk_prefix,disk_ext] 

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-jessie64"
  config.vm.box_version = "8.11.0"
  #config.vm.network "public_network"
  config.vm.post_up_message = [ "compilertron configuration stage" ]
  
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # Create disk for compiled objects
  config.vm.provider "virtualbox" do |v|
    unless File.exist?(compiledisk)
      v.customize ['createhd', '--filename', compiledisk, '--size', 50 * 1024]
    end
      v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', compiledisk]
  end

end

Vagrant.configure("2") do |config|
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "ansible/compilertron_setup.yml"
    ansible.extra_vars = {
        gcc_repo: gcc_repo
    }
  end
end