function E_out = revert_field(E_in)
    E_out = E_in;
    E_out.theta = 180-E_out.theta;
    if (E_out.theta == 0 ) ||(E_out.theta == 180)
        E_out.phi = 0;
    else
        E_out.phi = mod(E_out.phi + 180, 360);  
    end
end
