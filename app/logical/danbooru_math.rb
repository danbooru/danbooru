class DanbooruMath
  def self.ci_lower_bound(pos, n, confidence = 0.95)
    if n == 0
      return 0
    end

    z = Statistics2.pnormaldist(1-(1-confidence)/2)
    phat = 1.0*pos/n
    100 * (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)
  end
end
