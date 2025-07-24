#start simulation: "vouptargs" to preserve signal visibility  
vsim -novopt  work.Add_Saturate_TB -voptargs=+acc=npr

#do wave.do
log *-r
run 600ns
