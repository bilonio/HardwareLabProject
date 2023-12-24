

module decoder (output wire [3:0] F,
input wire A,B,C);
wire An,Bn,Cn,Dn,En,Fn,Gn,Hn,In,Jn,m0,m1,m2,m3,m4,m5;
//1st bit (alu_op[0])
not U0 (An,A);
xor U1(Bn,B,C);
and U2(m0,An,B);
and U3(m1,A,Bn);
or U4(F[0],m0,m1);

//2nd bit (alu_op[1])
and U5 (Cn,A,B);
not U6(Dn,B);
not U7(En,C);
and U8(m2,Dn,En);
or U9(F[1],m2,Cn);

//3rd bit (alu_op[2])
and U10(Fn,A,B);
xor U11(Gn,A,B);
not U12(Hn,C);
or U13(m3,Fn,Gn);
and U14(F[2],m3,Hn);

//4th bit (alu_op[3])
not U15(In,A);
xnor U16(Jn,A,C);
and U17(m4,In,C);
or U18(m5,m4,Jn);
and U19(F[3],m5,B);

endmodule 


