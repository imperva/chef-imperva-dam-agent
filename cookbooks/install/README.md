Readme for Imperva agent installation:

Important coockbook documents and folders:

1. The Cookbook recipie file is under: install/recipes/default.rb. this is the main installation flow.
2. All Files used in cookbook should be located here: install/files/ (files folder should be created if missing)
   for example: which_ragent_package_0234.sh , Imperva-ragent-RHEL-v7-kSMP-px86_64-b14.4.0.80.0.613296.tar.gz (all tar.gz files that will be used in installation)


for running chef client follow the following steps:
1.Make sure wich ragent, kabi file(if needed) and all ragent tar.gz files are replaced in install/files/ folder.
2.In recipie file(install/recipes/default.rb), first replace the missing information such as gw password, gw ip, installation path etc.(first 5-6 rows of recipie)
3.Run chef client for example:
  knife ssh 'name:chef_node_name' 'chef-client -o install' (-a ipaddress  -x root -P rootPassword)
          
  
  
important notice:
ragent_install_path and chef_installation_temp_dir must be same for install and uninstall.
for example:
ragent_install_path = '/opt/imperva/'  
chef_installation_temp_dir = '/tmp/chefinstallation/'
