
#####
# Change these settings to match your environment
#####
null = null

# FTP urls

##### 
# end of settings
#####

current_dir = File.dirname(File.expand_path(__FILE__))     
disk_prefix = 'installdisk'
disk_ext ='.vdi'      
installdisk = "%s/%s%s" % [current_dir,disk_prefix,disk_ext] 

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-jessie64"
  config.vm.box_version = "8.11.0"
  #config.vm.network "public_network"
  config.vm.post_up_message = [ "compilertron configuration stage" ]
  
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

end

Vagrant.configure("2") do |config|
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "ansible/compilertron_setup.yml"
    ansible.extra_vars = {
        null: null
    }
  end
end