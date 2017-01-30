using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    // Class to simply represent a cartesian coordinate
    class Coordinate
    {
        public Coordinate(Double x_in, Double y_in, Double z_in)
        {
            x = x_in;
            y = y_in;
            z = z_in;
        }

        public static Double distance(Coordinate a, Coordinate b)
        {
            return Math.Sqrt(Math.Pow(b.x - a.x, 2) + Math.Pow(b.y - a.y,2) + Math.Pow(b.z - a.z, 2));
        }

        public Double x, y, z;
    }
}
