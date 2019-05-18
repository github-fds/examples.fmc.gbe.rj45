#!/bin/csh -f

if ( -e top.wdb              ) /bin/rm -f  top.wdb             
if ( -e wave.vcd             ) /bin/rm -f  wave.vcd            
if ( -e webtalk.jou          ) /bin/rm -f  webtalk.jou         
if ( -e webtalk.log          ) /bin/rm -f  webtalk.log         
if ( -e xelab.log            ) /bin/rm -f  xelab.log           
if ( -e xelab.pb             ) /bin/rm -f  xelab.pb            
if ( -e xsim.jou             ) /bin/rm -f  xsim.jou            
if ( -e xsim.log             ) /bin/rm -f  xsim.log            
if ( -e xvlog.log            ) /bin/rm -f  xvlog.log           
if ( -e xvlog.pb             ) /bin/rm -f  xvlog.pb            
if ( -e .Xil                 ) /bin/rm -fr .Xil                
if ( -e xsim.dir             ) /bin/rm -fr xsim.dir            
/bin/rm -f  xsim_*.backup.jou   
/bin/rm -f  xsim_*.backup.log   
/bin/rm -f  webtalk_*.backup.jou
/bin/rm -f  webtalk_*.backup.log
