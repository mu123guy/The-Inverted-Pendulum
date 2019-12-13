clear,clc
syms x1 x2 F m real
x1dot = x2
x2dot = F/m
jac = jacobian([x1dot,x2dot],[x1,x2,F])