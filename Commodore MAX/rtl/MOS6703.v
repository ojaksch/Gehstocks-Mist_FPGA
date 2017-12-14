module MOS6703(

input [15:10]A,
inout [11:0]D,
input			CLK,//CLK
input 		BA,//BA
input			RW_IN,// RW

output reg	RAM,//RAM invert
output reg	EXRAM,//EXRAM invert
output reg	VIC,//VIC invert
output reg	SID,//SID invert
output reg	CIA,//CIA_PLA invert
output reg	COLRAM,//COLRAM invert
output reg	ROML,//ROML invert
output reg	ROMH,//ROMH invert
output reg	BUF,//to the 4066 COLOR Ram DATA
output reg	RW_OUT//RW_PLA invert

);



always @ (CLK)
begin
RAM = !(!A[11] & !A[12] & !A[13] & !A[14] & !A[15] & CLK & BA);
//# !A[11] & !A[12] & !A[13] & !CLK 
//# !A[11] & !A[12] & !A[13] & !BA;
EXRAM = !(A[11] & !A[12] & !A[13] & !A[14] & !A[15] & CLK & BA);
//# A[11] & !A[12] & !A[13] & !CLK
//# A[11] & !A[12] & !A[13] & !BA;
ROML = !(!A[13] & !A[14] & A[15] & CLK & BA);
ROMH = !(A[13] & A[14] & A[15] & CLK & BA);
//# A[12] & A[13] & !CLK
//# A[12] & A[13] & !BA;
SID = !(A[10] & !A[11] & A[12] & !A[13] & A[14] & A[15] & CLK & BA);
VIC = !(!A[10] & !A[11] & A[12] & !A[13] & A[14] & A[15] & CLK & BA);
COLRAM = !(!A[10] & A[11] & A[12] & !A[13] & A[14] & A[15] & CLK & BA); 
//# !CLK 
//# !BA;
BUF = (!A[10] & A[11] & A[12] & !A[13] & A[14] & A[15] & CLK & BA);
CIA = !(A[10] & A[11] & A[12] & !A[13] & A[14] & A[15] & CLK & BA);
RW_OUT = !(CLK & !RW_IN);
end



//GAL Code
/*!RAM = !A11 & !A12 & !A13 & !A14 & !A15 & CLK & BA 
!EXRAM = A11 & !A12 & !A13 & !A14 & !A15 & CLK & BA
# A11 & !A12 & !A13 & !CLK
# A11 & !A12 & !A13 & !BA;
!ROML = !A13 & !A14 & A15 & CLK & BA;
!ROMH = A13 & A14 & A15 & CLK & BA
# A12 & A13 & !CLK
# A12 & A13 & !BA;
!SID = A10 & !A11 & A12 & !A13 & A14 & A15 & CLK & BA;
!VIC = !A10 & !A11 & A12 & !A13 & A14 & A15 & CLK & BA;
!COLRAM = !A10 & A11 & A12 & !A13 & A14 & A15 & CLK & BA 
# !CLK 
# !BA;
BUF = !A10 & A11 & A12 & !A13 & A14 & A15 & CLK & BA;
!CIA = A10 & A11 & A12 & !A13 & A14 & A15 & CLK & BA;
!RW_OUT = CLK & !RW_IN;*/

endmodule 