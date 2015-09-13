knife bootstrap 10.0.0.10 -r 'role[database]'  -N database-01.example.net -x root -d my-fedora13 
knife bootstrap 10.0.0.11 -r 'role[database]' -N database-02.example.net -x root -d my-fedora13 
knife bootstrap 10.0.0.14 -r 'role[redis]' -N redis01.example.net -x root -d my-fedora13 
knife bootstrap 10.0.0.15 -r 'role[redis]' -N redis02.example.net -x root -d my-fedora13 
knife bootstrap 10.0.0.14 -r 'role[files]' -N files01.example.net -x root -d my-fedora13 
knife bootstrap 10.0.0.15 -r 'role[files]' -N files02.example.net -x root -d my-fedora13 
knife bootstrap 10.0.0.16 -r 'role[appdemo]' -N appdemo01.example.net -x root -d my-fedora13 
knife bootstrap 10.0.0.17 -r 'role[appdemo]' -N appdemo02.example.net -x root -d my-fedora13
