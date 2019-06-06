@ECHO OFF
:: Copyright (c) 2010 by Ando Ki.
:: All right reserved.
::
:: This code is distributed in the hope that it will
:: be useful to understand Ando Ki's book,
:: but WITHOUT ANY WARRANTY.

SET MODELSIMWORK=work
SET MODELSIMVLIB=vlib
SET MODELSIMVSIM=vsim
SET MODELSIMVCOM=vcom
SET MODELSIMVLOG=vlog

SET DESIGNTOP=top

IF EXIST %MODELSIMWORK% RMDIR /S/Q %MODELSIMWORK%
IF EXIST compile.log DEL /Q compile.log

%MODELSIMVLIB% %MODELSIMWORK%
%MODELSIMVLOG% -work %MODELSIMWORK% -lint -f modelsim.args >> compile.log 2>&1
%MODELSIMVSIM% -novopt -c -do "run -all; quit"^
              %MODELSIMWORK%.%DESIGNTOP% %MODELSIMWORK%.glbl

:END
PAUSE
