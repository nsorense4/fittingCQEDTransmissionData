function [array1, array2] = removeNan(array1, array2)
    nanIndex = isnan(array1);
    array1 = array1(not(nanIndex));
    array2 = array2(not(nanIndex));

    nanIndex = isnan(array2);
    array1 = array1(not(nanIndex));
    array2 = array2(not(nanIndex));