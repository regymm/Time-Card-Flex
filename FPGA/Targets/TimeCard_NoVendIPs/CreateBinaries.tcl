# ##########################################################################################
# Project: Time Card
#
# Author: Thomas Schaub, NetTimeLogic GmbH
#
# License: Copyright (c) 2022, NetTimeLogic GmbH, Switzerland, <contact@nettimelogic.com>
# All rights reserved.
#
# THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU LESSER GENERAL PUBLIC LICENSE AS
# PUBLISHED BY THE FREE SOFTWARE FOUNDATION, VERSION 3.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# LESSER GENERAL LESSER PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU LESSER GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM. IF NOT, SEE <http://www.gnu.org/licenses/>.
#
# ##########################################################################################

set ScriptFile [file normalize [info script]]
set ScriptFolder [file dirname $ScriptFile]

cd $ScriptFolder

# current time
set SystemTime [clock seconds]

# set the current synth run
current_run -synthesis [get_runs synth_1]
# set the current impl run
current_run -implementation [get_runs impl_1]

# run synthese
reset_run synth_1
launch_runs synth_1 -jobs 12
wait_on_run synth_1

# run implementation and bitstream
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1

set TimestampDate [clock format $SystemTime -format %Y_%m_%d]
set TimestampTime [clock format $SystemTime -format %H_%M_%S]
set Timestamp "$TimestampDate $TimestampTime"
set BinaryFolder "$ScriptFolder/Binaries/$Timestamp"

file mkdir $BinaryFolder

# date specific
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bit $BinaryFolder/TimeCardOS.bit
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bin $BinaryFolder/TimeCardOS.bin
write_hwdef -force -file $BinaryFolder/TimeCardOS.hdf

# latest always here
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bit $ScriptFolder/Binaries/TimeCardOS.bit
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bin $ScriptFolder/Binaries/TimeCardOS.bin
write_hwdef -force -file $ScriptFolder/Binaries/TimeCardOS.hdf

write_cfgmem -format BIN -interface SPIx4 -size 16 -loadbit "up 0x00000000 $ScriptFolder/Binaries/Golden_TimeCardOS.bit up 0x0400000 $ScriptFolder/Binaries/TimeCardOS.bit" -file $ScriptFolder/Binaries/Factory_TimeCardOS.bin -force
