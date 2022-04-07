Redme for Imperva agent uninstall:

Important coockbook documents and folders:

1. The Cookbook recipie file is under: uninstall/recipes/default.rb. this is the main uninstall flow.
2. No files needed for this phase

for running chef client follow the following steps:
1.In recipie file(uninstall/recipes/default.rb), first replace the missing information ragent_install_path and chef_installation_temp_dir(first 2 rows of recipie)
  make sure you give same agent install path and chef install path like in installation recipie.
  ragent_install_path is the path where agent is installed, usually will be /opt/imperva/
  chef_installation_temp_dir is where the chef folder was created on chef client machine during installation.for example '/tmp/chefinstallation/'
2.Run chef client from chef server for example:
  knife ssh 'name:chef_node_name' 'chef-client -o uninstall' (-a ipaddress  -x root -P rootPassword)
          
