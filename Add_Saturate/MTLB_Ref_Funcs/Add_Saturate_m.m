function c = Add_Saturate_m(a,b,u_width)

max_v = 2^u_width -1;
min_v = -(2^u_width);

c = a+b;
if c > max_v
    c = max_v;
elseif c < min_v
    c = min_v;
end