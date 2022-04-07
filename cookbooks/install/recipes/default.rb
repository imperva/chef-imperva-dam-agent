#
# Cookbook:: test
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.
wich_ragent_name = 'which_ragent_package_0234.sh'
ragent_installation_path = '/opt/imperva/'
chef_installation_temp_dir = '/tmp/chefinstallation/' 
kabi_file = 'kabi.txt'
gw_ip = '10.100.87.156'
gw_password = 'Barbapapa12#'
version_for_wich_ragent = '14.0.0'


if ::File.exist?(ragent_installation_path+'ragent/bin/racli')
Chef::Log.error('Skipping installation, agent is already istalled')
return
end

puts "creating directory"
directory chef_installation_temp_dir do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
end


puts "copying which ragent package"
cookbook_file chef_installation_temp_dir+wich_ragent_name do
        source wich_ragent_name
        owner 'root'
        group 'root'
        mode '0755'
        action :create
end


puts "create directory for tar"
directory chef_installation_temp_dir+'pkg' do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
end


ruby_block "run wich ragent to find agent name" do
  block do
      node.run_state['file_path'] = `sh #{chef_installation_temp_dir}#{wich_ragent_name} -v #{version_for_wich_ragent} | grep -Po 'Imperva-ragent-.*gz' |  head -1|tr -d '\n'`
  end
end

####

puts "copying tar.gz"
cookbook_file chef_installation_temp_dir+'Imperva-ragent.tar.gz' do
        source lazy { node.run_state['file_path'] }
        owner 'root'
        group 'root'
        mode '0755'
        action :create
		ignore_failure true
end

ruby_block "chef if agent exists in files folder" do
  block do
  if !::File.exist?(chef_installation_temp_dir+'Imperva-ragent.tar.gz')
    Chef::Log.error("agent tar.gz "+ node.run_state['file_path'] +" file is missing, please add it to install/files folder")
	raise "missing installation file: "+node.run_state['file_path']+" please place it in install/files folder"
  end
  end
end

execute "Untaring tar.gz" do
command <<-EOF
	tar xf #{chef_installation_temp_dir}Imperva-ragent.tar.gz -C #{chef_installation_temp_dir}/pkg 
EOF
end

puts "copying kabi"
cookbook_file chef_installation_temp_dir+'kabi.txt' do
        source kabi_file
        owner 'root'
        group 'root'
        mode '0755'
        action :create
		ignore_failure true
end

execute "check if needs kabi file and checks if exists" do	
	if %x($(find #{chef_installation_temp_dir}/pkg/ -name 'Imperva-ragent-*') -c -d #{ragent_installation_path} | grep -q "Kabi file is missing") do
		if ::File.exist?('/var/www/html/login.php') do
		   #install with -k kabi_file
			%x((find #{chef_installation_temp_dir}/pkg/ -name 'Imperva-ragent-*') -n -d #{ragent_installation_path} -k #{{chef_installation_temp_dir}+'kabi.txt')
		else
		Chef::Log.error("kabi file is missing, please add it to install/files folder")
		raise "kabi file is missing, please add it to install/files folder"
		end
	else
		%x((find #{chef_installation_temp_dir}/pkg/ -name 'Imperva-ragent-*') -n -d #{ragent_installation_path})
	end
end

execute "find installation file and install" do
command <<-EOF
	$(find #{chef_installation_temp_dir}/pkg/ -name 'Imperva-ragent-*') -n -d #{ragent_installation_path}
EOF
	live_stream true
end

execute "create registartion file and register agent" do
command <<-EOF
        echo "#{ragent_installation_path}ragent/bin/cli --dcfg #{ragent_installation_path}ragent/etc --dtarget #{ragent_installation_path}ragent/etc --dlog #{ragent_installation_path}ragent/etc/logs/cli registration advanced-register registration-type=Primary is-db-agent=true tunnel-protocol=TCP gw-ip=#{gw_ip}  gw-port=443 manual-settings-activation=Automatic monitor-network-channels=Both password=#{gw_password} ragent-name=$(hostname)">#{chef_installation_temp_dir}/pkg/registration.sh
        chmod 777 #{chef_installation_temp_dir}/pkg/registration.sh
		echo -e "\e[1;35mCreated registration file $(cat #{chef_installation_temp_dir}/pkg/registration.sh)"
		echo -e "\e[1;35mRegistering agent"
        sh #{chef_installation_temp_dir}/pkg/registration.sh
EOF
	live_stream true
end

execute "start agent" do
command <<-EOF
    sh #{ragent_installation_path}ragent/bin/rainit start
EOF
end


execute "find installation file and install agent installer" do
command <<-EOF
	$(find #{chef_installation_temp_dir}/pkg/ -name 'Imperva-ragentinstaller*') -n -d #{ragent_installation_path}
EOF
	live_stream true
end

execute "create registartion file and register agent installer" do
command <<-EOF
        echo "#{ragent_installation_path}installer/bin/cliinstaller --dcfg #{ragent_installation_path}installer/etc --dtarget #{ragent_installation_path}installer/etc --dlog #{ragent_installation_path}installer/etc/logs/cli registration advanced-register registration-type=Primary is-db-agent=true tunnel-protocol=TCP gw-ip=#{gw_ip}  gw-port=443 manual-settings-activation=Automatic monitor-network-channels=Both password=#{gw_password} ragent-name=$(hostname)">#{chef_installation_temp_dir}/pkg/InstallerRegistration.sh
        chmod 777 #{chef_installation_temp_dir}/pkg/InstallerRegistration.sh
		echo -e "\e[1;35mCreated registration file $(cat #{chef_installation_temp_dir}/pkg/InstallerRegistration.sh)"
		echo -e "\e[1;35mRegistering agent"
        sh #{chef_installation_temp_dir}/pkg/InstallerRegistration.sh
EOF
	live_stream true
end

execute "start agent installer" do
command <<-EOF
    sh #{ragent_installation_path}installer/bin/rainstallerinit start
EOF
end

execute "checking status of agent and installer" do
command <<-EOF
	echo -e "\e[1;35mHostname parameter: $(hostname)"
	echo -e "\e[1;35mStatus of agent: $(echo q|sudo #{ragent_installation_path}/ragent/bin/racli 2>/dev/null|egrep "Release|Status")"
	echo -e "\e[1;35mStatus of installer: $(echo q|sudo #{ragent_installation_path}/installer/bin/racli 2>/dev/null|egrep "Release|Status")"
EOF
	live_stream true
end
