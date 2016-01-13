classdef Archive
  properties
    dim  = 1;           % dimension of the input space X (determined from x_mean)
    X    = [];          % archive - input-space data
    y    = [];          % archive - dependent-space data
    gens = [];          % archive - generations of the data where they come from
  end

  methods
    function obj = Archive(dimension)
      % constructor
      obj.dim = dimension;
    end

    function obj = save(obj, X, y, generation)
      % save data (@X,@y) from @generation to the archive
      assert(size(X,1) == size(y,1), 'Archive.save: dimensions X and y mismatch.');
      assert(size(y,2) == 1, 'Archive.save: y is not a column vector.');
      assert(size(X,2) == obj.dim, 'Archive.save: dimension of X''s and Archive.dim mismatch.');
      if (~isempty(obj.X))
        isNotYetSaved = ~(ismember(X, obj.X, 'rows'));
        % TODO: put here some TolX criterion, not this silly 'ismember()'
      else
        isNotYetSaved = true(size(X,1),1);
      end
      obj.X = [obj.X; X(isNotYetSaved,:)];
      obj.y = [obj.y; y(isNotYetSaved,:)];
      obj.gens = [obj.gens; generation * ones(sum(isNotYetSaved),1)];
    end
    
    function [X, y] = getDataFromGenerations(obj, generations)
      % return data from generation(s) defined in scalar/vector @generations
      dataIdxs = ismember(obj.gens, generations);
      X = obj.X(dataIdxs, :);
      y = obj.y(dataIdxs);
    end

    function [X, y] = getDataNearPoint(obj, n, x, rangeSigma, sigma, BD, generations)
      % returns up to 'n' data within distance of 'rangeSigma' along the point 'x'
      % using (sigma*BD)-metric
      % if more than 'n' data are closer than 'rangeSigma', k-means clustering is
      % performed
      % if (n == 0), all the available data are returned
      % 
      % generations is optional param
      
      if nargin < 7
          src_X = obj.X;
          src_y = obj.y;
      else 
          [src_X, src_y] = obj.getDataFromGenerations(generations);
      end
      
      nData = length(src_y);
      X = []; y = [];
      
      if (nData == 0)
        return;
      end
      
      % compute coordinates in the (sigma*BD)-basis
      BDinv = inv(sigma*BD);
      xTransf = ( BDinv * (src_X - repmat(x,nData,1))' )';
      
      % take the points closer than *rangeSigma*
      diff = sum(xTransf.^2, 2);
      isInRange = diff < (rangeSigma ^ 2);

      if (sum(isInRange) <= n  ||  n <= 0)
        X = src_X(isInRange,:);
        y = src_y(isInRange);
      else
        % cluster the transformed data into n clusters
        closerDataX = xTransf(isInRange,:);
        closerDataY = src_y(isInRange);
        closerThan2SigmaIdx = find(isInRange);
        try
          [~, ~, ~, D] = kmeans(closerDataX, n);
          % D = ('n' x 'k') distances to the clusters' centroids
          % find the points nearest to the clusters' centers
          [~, closestToCentroid] = min(D, [], 1);
          for closestIdx = closestToCentroid
            % return the original coordinates, not the transformed
            X = [X; src_X(closerThan2SigmaIdx(closestIdx),:)];
            y = [y; closerDataY(closestIdx)];
          end
        catch err
          warning('Archive.getDataNearPoint(): %s\n', err.message);
          randp = randperm(length(closerThan2SigmaIdx));
          X = [X; src_X(closerThan2SigmaIdx(randp(1:n)),:)];
          y = [y; closerDataY(randp(1:n))];
        end
      end
    end
  end
end
