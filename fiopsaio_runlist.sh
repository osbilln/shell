# knife bootstrap 10.0.10.245


# knife node run_list add fiopsaio.fluigidentity.com 'role[base]'
# knife node run_list add fiopsaio.fluigidentity.com 'role[apache]'
# knife node run_list add fiopsaio.fluigidentity.com 'role[tomcat]'
# knife node run_list add fiopsaio.fluigidentity.com 'role[fi-aio-deploy]'

###
knife node run_list remove fiopsaio.fluigidentity.com 'role[base]'
knife node run_list remove fiopsaio.fluigidentity.com 'role[apache]'
knife node run_list remove fiopsaio.fluigidentity.com 'role[tomcat]'
