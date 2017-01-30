using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    class TemporalAlignment
    {
        public TemporalAlignment(MLApp.MLApp matlabRef, int numSAUs_in, int id_ref_in)
        {
            matlab = matlabRef;
            alignDmwResults = new List<object>();
            skeleton2skeletonResults = new List<object>();
            numSAUs = numSAUs_in;
            id_ref = id_ref_in;
            SkeletonT = new List<Double[,]>();
        }

        // Note: Due to the nature of the calculations the conversions have to be executed within this function
        public void Execute(List<Double[,]> saus)
        {

            for (int i = 0; i < numSAUs; i++)
            {
                object resultAlignDmw = null;
                object resultSkeleton2Skeleton = null;

                matlab.Feval("alignDmw", 4, out resultAlignDmw, saus[id_ref], saus[i], 3, 3, "Method", 1, "List", SkeletonHandler.List);
                alignDmwResults.Add(resultAlignDmw);
                object[] tmpResultAlignDmw = resultAlignDmw as object[];
                Double[,] matching = (Double[,])tmpResultAlignDmw[0];

                matlab.Feval("Skeleton2Skeleton", 1, out resultSkeleton2Skeleton, saus[i], matching);
                skeleton2skeletonResults.Add(resultSkeleton2Skeleton);

                // Extract skeleton2skeleton's value
                object[] tmpResultSkeleton2Skeleton = resultSkeleton2Skeleton as object[];
                Double [,] skeleton2Skeleton = (Double[,])tmpResultSkeleton2Skeleton[0];
                SkeletonT.Add(skeleton2Skeleton);
            }
        }

        // Getters
        public List<Double[,]> getSkeletonT() { return SkeletonT; }

       // Raw Data
        private MLApp.MLApp matlab;       // Matlab reference
        private List<object> alignDmwResults;
        private List<object> skeleton2skeletonResults;

        private List<Double[,]> SkeletonT;

        private int numSAUs;
        private int id_ref;
    }
}
