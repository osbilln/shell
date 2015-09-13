
https://54.205.158.194/cloudpass/asset/image/company/small/0/default.png

/opt/chef/embedded/bin/ruby /usr/bin/chef-client -l debug -d -P /var/run/chef/client.pid -L /var/log/chef/client.log -c /etc/chef/client.rb -i 600 -s 5


knife node run_list remove vicentegoetten 'role[fi-aio-deploy]'
knife node run_list remove vicentegoetten 'recipes[fi-aio-deploy]'
knife node run_list add vicentegoetten 'role[fi-aio-deploy]'


knife node show vicentegoetten
knife node run_list add vicentegoetten 'recipe[fi-aio-deploy::fi-aio-deploy],role[fi-aio-deploy]'
knife node run_list delete vicentegoetten 'recipe[fi-aio-deploy::fi-aio-deploy]'
knife node run_list remove vicentegoetten 'recipe[fi-aio-deploy::fi-aio-deploy]'
knife node show vicentegoetten
knife node run_list remove vicentegoetten 'role[fi-aio-deploy]'
knife node show vicentegoetten
knife node run_list add vicentegoetten 'role[fi-aio-deploy]'
knife node show vicentegoetten
knife node run_list add vicentegoetten 'recipes[fi-aio-deploy]'
knife node run_list add vicentegoetten 'roles[fi-aio-deploy]'
knife node run_list add vicentegoetten 'role[fi-aio-deploy]'
knife node show vicentegoetten
knife node show vicentegoetten

knife node run_list add ssapp09p.zubops.net "role[fi-aio-deploy]"
