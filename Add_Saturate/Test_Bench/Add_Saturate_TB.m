clear 
clc
!./Test_Bench/cleanvsim.sh
[sys_code, sys_msg] = system('vsim -c -do Test_Bench/compileRTL.do');
if sys_code ~=0
    fprintf(sys_msg)
    fprintf('\n')
    return
end
N = 7;  % signed Bitwidth
for i_trial = 1:200
    fIDa =-1;
    while fIDa<0
        fIDa= fopen('Sim_IO/a_vec.txt', 'w');
    end
    fIDb =-1;
    while fIDb<0
        fIDb = fopen('Sim_IO/b_vec.txt', 'w');
    end
    
    for i=1:5
        a_vec(i,1) = randi([-(2^(N-1)),(2^(N-1))-1]);
        tmp =nde2bi(a_vec(i,1) , N);
        fprintf(fIDa, [tmp,'\n']);
        
        b_vec(i,1) = randi([-(2^(N-1)),(2^(N-1))-1]);
        tmp =nde2bi(b_vec(i,1) , N);
        fprintf(fIDb, [tmp,'\n']);
        
        c_vec(i,1) = Add_Saturate_m(a_vec(i,1), b_vec(i,1), N-1);
    end
    mtlb_vec = [a_vec,b_vec, c_vec];
    fclose (fIDa);
    fclose (fIDb);
    [sys_code, sys_msg] = system('vsim -c -do Test_Bench/runSim.do');
    if sys_code ~=0
        fprintf(sys_msg)
        fprintf('\n')
    end
    pause(0.1)
    run("Sim_IO/IO_file")
    if isequal(rtl_vec, mtlb_vec)
        disp("************** PASS **************")
    else 
        disp("************** FAIL **************")
    end
end