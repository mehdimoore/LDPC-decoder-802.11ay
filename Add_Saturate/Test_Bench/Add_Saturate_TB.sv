module Add_Saturate_TB();

	parameter                                         N = 7;
	reg [N-1:0]                                       a_vec[0:4];
	reg [N-1:0]                                       b_vec[0:4];
	initial begin
		$readmemb("Sim_IO/a_vec.txt",a_vec);
		$readmemb("Sim_IO/b_vec.txt",b_vec);
	end
	
	reg signed  [N-1:0]                               i_a;
	reg signed  [N-1:0]                               i_b;
	wire signed [N-1:0]                               o_c;
	Add_Saturate #(.N(N)) UUT(
			.i_a(i_a),
			.i_b(i_b),
			.o_c(o_c)    
		);
	
	
	integer fID_IO;
	initial begin
		fID_IO =$fopen("Sim_IO/IO_file.m");
		$fwrite(fID_IO,"x=Inf;" ,"\n");
	end

	string str_;
	initial begin
		i_a = a_vec[0];
		i_b = b_vec[0];
		#1;
		str_ = $psprintf("rtl_vec(1,:) = [%d,%d,%d];", i_a,i_b,o_c);
		$fwrite(fID_IO, str_,"\n");
		//    $display ("a = %d,  b = %d,  c = %d", $signed(i_a),$signed(i_b), $signed(o_c));

		i_a = a_vec[1];
		i_b = b_vec[1];
		#1;
		str_ = $psprintf("rtl_vec(2,:) = [%d,%d,%d];", i_a,i_b,o_c);
		$fwrite(fID_IO, str_,"\n");
		//    $display ("a = %d,  b = %d,  c = %d", $signed(i_a),$signed(i_b), $signed(o_c));

		i_a = a_vec[2];
		i_b = b_vec[2];
		#1;
		str_ = $psprintf("rtl_vec(3,:) = [%d,%d,%d];", i_a,i_b,o_c);
		$fwrite(fID_IO, str_,"\n");
		//    $display ("a = %d,  b = %d,  c = %d", $signed(i_a),$signed(i_b), $signed(o_c));
 
		i_a = a_vec[3];
		i_b = b_vec[3];
		#1;
		str_ = $psprintf("rtl_vec(4,:) = [%d,%d,%d];", i_a,i_b,o_c);
		$fwrite(fID_IO, str_,"\n");
		//    $display ("a = %d,  b = %d,  c = %d", $signed(i_a),$signed(i_b), $signed(o_c));

		i_a = a_vec[4];
		i_b = b_vec[4];
		#1;
		str_ = $psprintf("rtl_vec(5,:) = [%d,%d,%d];", i_a,i_b,o_c);
		$fwrite(fID_IO, str_,"\n");
		//    $display ("a = %d,  b = %d,  c = %d", $signed(i_a),$signed(i_b), $signed(o_c));

		//#200;
		//$finish;
	end
endmodule