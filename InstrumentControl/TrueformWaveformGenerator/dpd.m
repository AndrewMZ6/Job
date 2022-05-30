function table = dpd(coeffs, input_values, k)
%DPD Summary of this function goes here
%   Detailed explanation goes here
    len = length(input_values);
    
    er = 0.00000001;
    d = 0.1;
    
    for i = 1:len
        e = 1; phi = 0;
%         disp(['i = ', num2str(i)]);
%         pause(1)
        s = input_values(i);
%         disp(['s = ', num2str(s), ', i = ', num2str(i)]);
%         pause(1)
        while abs(e) > er
            A = s + phi;
%             disp(['A = ', num2str(A), ', i = ', num2str(i)]);
%             pause(1)
            P = polyval(coeffs, A);
%             disp(['P = ', num2str(P), ', i = ', num2str(i)]);
%             pause(1)
            P = P./k;
%             disp(['P = ', num2str(P), ', i = ', num2str(i)]);
%             pause(1)
            e = s - P;
%             disp(['e = ', num2str(e), ', i = ', num2str(i)]);
%             pause(1)
            phi = phi + d*e;
%             disp(['phi = ', num2str(phi), ', i = ', num2str(i)]);
%             pause(1)
        end

        table(i) = phi;
    end
end

