function input = perlin_noise(input)

input = 1e3
division = 10;
n = input/division;
query = 1:input;





i = 1;
j = 1;
w = sqrt(n)
while w > 3
        value_fine = interp1([d(i) d(i+1)], j-division, 'spline');
        input =  input + j * d(1:n);
        w = w - ceil(w/2 - 1);
        i = i + 1;
        j = j + division;
end
plot(input)
% 
% for i=1:n
%     last_num = current_num;
%     current_num = randn();
%     d(i) = ;
% end
% plot(d)