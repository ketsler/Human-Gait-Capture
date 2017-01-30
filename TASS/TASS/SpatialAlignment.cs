using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    class SpatialAlignment
    {
        public SpatialAlignment(MLApp.MLApp matlabRef)
        {
            matlab = matlabRef;
            spatialAlignmentResult = new List<object>();
            spatiallyAlignedSAUs = new List<Double[,]>();
        }

        public void Execute(List<Double[,]> saus)
        {
            foreach (Double[,] sau in saus)
            {
                object result = null;
                matlab.Feval("SpatialAlignment", 1, out result, sau); //, "@FeetDistance", "@WalkingBackwardY");

                spatialAlignmentResult.Add(result);
            }

        }

        // Convert data from Raw objects to C# typed objects
        public void typeTheRawData()
        {
            foreach(object o in spatialAlignmentResult)
            {
                object[] arrayO = o as object[];
                Double[,] tmp = (Double[,])arrayO[0];
                spatiallyAlignedSAUs.Add(tmp);
            }
        }

        // Debugging Function
        public void printAlignedSAUs()
        {
            foreach(Double[,] dl in spatiallyAlignedSAUs)
            {
                foreach(Double d in dl)
                {
                    Console.WriteLine(d.ToString());
                }
            }
        }

        // Getters
        public List<Double[,]> getAlignedSAUs() { return spatiallyAlignedSAUs; }

        // Raw Data
        private MLApp.MLApp matlab;                     // Matlab reference
        private List<object> spatialAlignmentResult;    // Raw Matlab Result

        // Typed Data
        private List<Double[,]> spatiallyAlignedSAUs;
    }
}
