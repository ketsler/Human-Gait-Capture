using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    class ReferenceSAUHandler
    {
        public ReferenceSAUHandler(MLApp.MLApp matlabRef, int numSAUs_in)
        {
            matlab = matlabRef;
            temporalScore = new Double[numSAUs_in, numSAUs_in];
            spatialScore = new Double[numSAUs_in, numSAUs_in];
            spatialScore2 = new Double[numSAUs_in];
            Array.Clear(spatialScore2, 0, numSAUs_in);
            numSAUs = numSAUs_in;
            id_ref = -1;

            alignDmwResults = new List<object>();
            nonLinearityScoreResults = new List<object>();
            skeleton2skeletonResults = new List<object>();
            skeletonDistanceResults = new List<object>();
        }

        // Note: Due to the nature of the calculations the conversions have to be executed within this function
        public void Execute(List<Double[,]> saus)
        {

            for(int i = 0; i < numSAUs; i++)
            {
                for(int j = 0; j < numSAUs; j++)
                {
                    object resultAlignDmw = null;
                    object resultNonLinearityScore = null;
                    object resultSkeleton2Skeleton = null;
                    object resultSkeletonDistance = null;

                    matlab.Feval("alignDmw", 4, out resultAlignDmw, saus[i], saus[j], 3, 3, "Method", 1, "List", SkeletonHandler.List);
                    alignDmwResults.Add(resultAlignDmw);
                    object[] tmpResultAlignDmw = resultAlignDmw as object[];
                    Double[,] matching = (Double[,])tmpResultAlignDmw[0];

                    matlab.Feval("NonLinearityScore", 1, out resultNonLinearityScore, matching);
                    nonLinearityScoreResults.Add(resultNonLinearityScore);
                    object[] tmpNonLinearityScore = resultNonLinearityScore as object[];
                    Double tmpResultNonLinearityScore = (Double)tmpNonLinearityScore[0];
                    temporalScore[i, j] = tmpResultNonLinearityScore;

                    matlab.Feval("Skeleton2Skeleton", 1, out resultSkeleton2Skeleton, saus[j], matching);
                    skeleton2skeletonResults.Add(resultSkeleton2Skeleton);

                    // Extract skeleton2skeleton's value
                    object[] tmpResultSkeleton2Skeleton = resultSkeleton2Skeleton as object[];
                    Double[,] skeleton2skeleton = (Double[,])tmpResultSkeleton2Skeleton[0];

                    matlab.Feval("SkeletonDistance", 1, out resultSkeletonDistance, saus[i], skeleton2skeleton);
                    skeletonDistanceResults.Add(resultSkeletonDistance);
                    object[] tmpSkeletonDistance = resultSkeletonDistance as object[];
                    Double tmpSkeletonDistanceResults = (Double)tmpSkeletonDistance[0];
                    spatialScore[i, j] = tmpSkeletonDistanceResults;

                }
            }
            calculateSpatialScore2();
            findIdRef();
        }

        // For debugging purposes
        public void printTemporalScore()
        {
            foreach(Double d in temporalScore)
            {
                Console.WriteLine(d.ToString());
            }
        }

        // For debugging purposes
        public void printSpatialScore()
        {
            foreach(Double d in spatialScore)
            {
                Console.WriteLine(d.ToString());
            }
        }

        // Sum up the second dimension
        public void calculateSpatialScore2()
        {
            for(int i = 0; i < numSAUs; i++)
            {
                for(int j = 0; j < numSAUs; j++)
                {
                    spatialScore2[i] += spatialScore[i,j];
                }
            }
        }

        // find minimum in spatialscore2 - id_ref
        public void findIdRef()
        {
            int smallestIndex = 0;
            Double smallestValue = spatialScore2[0];
            for(int i = 0; i < numSAUs; i++)
            {
                if(spatialScore2[i] < smallestValue)
                {
                    smallestValue = spatialScore2[i];
                    smallestIndex = i;
                }
            }
            id_ref = smallestIndex;
        }

        public void printSpatialScore2()
        {
            foreach(Double d in spatialScore2)
            {
                Console.WriteLine(d.ToString());
            }

        }

        // Getters
        public int getNumSAUs() { return numSAUs; }
        public int getIdRef() { return id_ref; }
        public Double[,] getTemporalScore() { return temporalScore; }
        public Double[,] getSpatialScore() { return spatialScore; }
        public Double[] getSpatialScore2() { return spatialScore2; }

        // Raw Data
        private MLApp.MLApp matlab;       // Matlab reference
        private List<object> alignDmwResults;
        private List<object> nonLinearityScoreResults;
        private List<object> skeleton2skeletonResults;
        private List<object> skeletonDistanceResults;

        private int numSAUs;
        private int id_ref;

        private Double[,] temporalScore;
        private Double[,] spatialScore;
        private Double[] spatialScore2;

    }
}