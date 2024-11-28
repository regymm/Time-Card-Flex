//*****************************************************************************************
// Project: Time Card
//
// Author: Thomas Schaub, NetTimeLogic GmbH
//
// License: Copyright (c) 2022, NetTimeLogic GmbH, Switzerland, <contact@nettimelogic.com>
// All rights reserved.
//
// THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
// IT UNDER THE TERMS OF THE GNU LESSER GENERAL PUBLIC LICENSE AS
// PUBLISHED BY THE FREE SOFTWARE FOUNDATION, VERSION 3.
//
// THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
// WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
// LESSER GENERAL LESSER PUBLIC LICENSE FOR MORE DETAILS.
//
// YOU SHOULD HAVE RECEIVED A COPY OF THE GNU LESSER GENERAL PUBLIC LICENSE
// ALONG WITH THIS PROGRAM. IF NOT, SEE <http://www.gnu.org/licenses/>.
//

module BufgMux_IPI(
input wire ClkIn0_ClkIn,
input wire ClkIn1_ClkIn,
input wire SelecteClk1_EnIn,
output wire ClkOut_ClkOut
);

  BUFGMUX #(.CLK_SEL_TYPE("ASYNC"))
  BufgMux_Inst(
    .O(ClkOut_ClkOut),
    .I0(ClkIn0_ClkIn),
    .I1(ClkIn1_ClkIn),
    .S(SelecteClk1_EnIn));

endmodule
