function output = Check_neighbor(output_img, i, j, count)
%CHECK_NEIGHBOR Use the neighbor pixels to correct the pixel(i,j)
%   output_img : the source image
%   i, j : location
%   count : this picture's avg

    size = output_img;
    if i-1 > 0
        count = count + ook(output_img(i-1, j) );
    end
    if j-1 > 0
        count = count + ook(output_img(i, j-1) );
    end
    if j+1 < size(2)
        count = count + ook(output_img(i, j+1) );
    end
    if i+1 < size(1)
        count = count + ook(output_img(i+1, j) );
    end
    
    if count >= 0
        output = output_img(i,j) + 251;
    else
        output = output_img(i,j);
    end
end

function r = ook(a)
    if a < 5 || a > 250
        r = 0;
    else
        r = a - 120;
        r = r / abs(r);
    end
end
