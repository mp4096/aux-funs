function der = LieDer(nDer, direction, funToDer, x)
    der = funToDer;
    for i = 1 : nDer
        der = jacobian(der, x)*direction;
    end
end