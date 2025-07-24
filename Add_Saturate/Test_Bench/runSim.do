#start simulation: "vouptargs" to preserve signal visibility  
vsim work.Add_Saturate_TB -voptargs=+acc=npr

log * -r
#run -all
run 500ns
quit
