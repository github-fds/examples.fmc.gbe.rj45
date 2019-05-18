@ECHO OFF

IF EXIST top.wdb               DEL   /Q   top.wdb             
IF EXIST wave.vcd              DEL   /Q   wave.vcd            
IF EXIST webtalk_*.backup.jou  DEL   /Q   webtalk_*.backup.jou
IF EXIST webtalk_*.backup.log  DEL   /Q   webtalk_*.backup.log
IF EXIST webtalk.jou           DEL   /Q   webtalk.jou         
IF EXIST webtalk.log           DEL   /Q   webtalk.log         
IF EXIST xelab.log             DEL   /Q   xelab.log           
IF EXIST xelab.pb              DEL   /Q   xelab.pb            
IF EXIST xsim_*.backup.jou     DEL   /Q   xsim_*.backup.jou   
IF EXIST xsim_*.backup.log     DEL   /Q   xsim_*.backup.log   
IF EXIST xsim.jou              DEL   /Q   xsim.jou            
IF EXIST xsim.log              DEL   /Q   xsim.log            
IF EXIST xvlog.log             DEL   /Q   xvlog.log           
IF EXIST xvlog.pb              DEL   /Q   xvlog.pb            
IF EXIST .Xil                  RMDIR /Q/S .Xil                
IF EXIST xsim.dir              RMDIR /Q/S xsim.dir            
