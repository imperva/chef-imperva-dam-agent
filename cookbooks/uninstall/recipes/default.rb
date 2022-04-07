#
# Cookbook:: uninstall
# Recipe:: default


ragent_install_path = '/opt/imperva/'
chef_installation_temp_dir = '/tmp/chefinstallation/'

execute "uninstalling agent" do
command <<-EOF	
		#{ragent_install_path}ragent/bin/uninstall
		#{ragent_install_path}installer/bin/uninstall
		rm -rf #{chef_installation_temp_dir}
EOF
end