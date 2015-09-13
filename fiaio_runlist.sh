# knife bootstrap 10.0.10.245


knife node run_list add fiaio 'role[base]'
knife node run_list add fiaio 'role[apache]'
knife node run_list add fiaio 'role[tomcat]'
knife node run_list add fiaio 'role[fi-aio-test]'

###
#knife node run_list remove fiaio.fluigidentity.com 'role[base]'
#knife node run_list remove fiaio.fluigidentity.com 'role[apache]'
#knife node run_list remove fiaio.fluigidentity.com 'role[tomcat]'
