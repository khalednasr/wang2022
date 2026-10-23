function [ THETA, PHI, num_orient ] = Efield_orientation(orientation_case)
%% E-field orientations
% Possible combinations of (theta, phi): 
% (7,6) -> (7-2)*6/2+1=16 -> 256 ** run this, corrsponds to 6 azimuthal rotations in TMS paper. 
% (7,8) -> (7-2)*8/2+1=21-> 441
% (7,12)-> (7-2)*12/2+1=31-> 961

n_theta_half = 3;                   % 3 between 0 to pi/2
n_theta = n_theta_half * 2 + 1;     % 7 between 0 to pi
theta = rad2deg( acos(1 - 2 * (0: 1/(n_theta_half*2) : 1)));
theta = round(theta, 1);            % 1 digit after decimal point

n_phi = 6;                          % 6 phis between 0 to 2*pi, 60 deg
% n_phi = 12;                          % 12 phis between 0 to 2*pi, 30 deg
dphi= 2*pi/n_phi;
phi = rad2deg( linspace(0, 2*pi - dphi, n_phi));
phi = round(phi,1);

n_phi_half = n_phi / 2;             % half the number between 0 to pi
phi_front = phi(1:n_phi_half);

switch orientation_case
    case 0
        % Orientations for one E-field, half the sphere, no south pole,
        % 16->256
        THETA =  [theta(1), kron( theta(2:end-1), ones([1,n_phi_half]) )];
        PHI =    [0,        repmat( phi_front, [1, n_theta-2] )         ];
    case 1
        % Orientations for one E-field, half the sphere, + south pole,
        % 17->289
        THETA =  [theta(1), kron( theta(2:end-1), ones([1,n_phi_half]) ), theta(end)];
        PHI =    [0,        repmat( phi_front, [1, n_theta-2] )         , 0];
    case 2  %%##
        % Orientations for one E-field, half the sphere, + south pole, + antimeridian,
        % 22->484
        n_phi_half = n_phi / 2 + 1;             % half the number between 0 to pi
        phi_front = phi(1:n_phi_half);

        THETA =  [theta(1), kron( theta(2:end-1), ones([1,n_phi_half]) ), theta(end)];
        PHI =    [0,        repmat( phi_front, [1, n_theta-2] )         , 0];
    case 3
        % Orientations for one E-field, entire sphere, 32->1024
        THETA =  [theta(1), kron( theta(2:end-1), ones([1,n_phi]) ), theta(end)];
        PHI =    [0,        repmat( phi, [1, n_theta-2] )          , 0];
    case 4  % same as 1, but with phi denser
        % Orientations for one E-field, half the sphere, + south pole, but
        % with phi denser, 32->1024
        n_phi = 12;                          % phis between 0 to 2*pi
        dphi= 2*pi/n_phi;
        phi = rad2deg( linspace(0, 2*pi - dphi, n_phi));
        phi = round(phi,1);
        
        n_phi_half = n_phi / 2;             % half the number between 0 to pi
        phi_front = phi(1:n_phi_half);

        THETA =  [theta(1), kron( theta(2:end-1), ones([1,n_phi_half]) ), theta(end)];
        PHI =    [0,        repmat( phi_front, [1, n_theta-2] )         , 0];
end
num_orient = length(THETA);
end
