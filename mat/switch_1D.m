function switch_1D(simulation, E_field, I_inj,kk)
switch kk
    case 1
        run_LFS;
    case 2
        run_HFS;
    case 3
        run_HFS_10;
    case 4
        run_AM_HFS;
        
end

end
