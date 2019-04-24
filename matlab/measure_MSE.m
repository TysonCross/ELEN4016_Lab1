    System_parameters;

    MSE = gsubtract(out.output_BB,out.output_NN);
    max_MSE = max(abs(MSE))
    plot(MSE)