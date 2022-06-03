function amplified = ampl(coeffs, input)
%AMPL Summary of this function goes here
%   Detailed explanation goes here
    modules = abs(input);
    angles = angle(input);
    
    amp_modules = polyval(coeffs, modules);

    switch isreal(input)
        case 1
            amplified = real(amp_modules.*exp(1i*angles));
        case 0
            amplified = amp_modules.*exp(1i*angles);
    end
end

