using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    class SpatialSummarization
    {
        public SpatialSummarization(MLApp.MLApp matlabRef, Double[,] spatialScore_in, int id_ref_in, List<Double[,]> SkeletonT_in, int numSAUs_in)
        {
            matlab = matlabRef;
            spatialScore = spatialScore_in;
            id_ref = id_ref_in;
            SkeletonT = SkeletonT_in;
            numSAUs = numSAUs_in;
            SkeletonTIndices = new List<int>();
            SkeletonInlier = new List<Double[,]>();
        }

        public void Execute()
        {
            calculatePartialSpatialScore();
            calculateMedian();
            findSkeletonTIndices();
            findSkeletonR();
        }

        public Double calculateMedian()
        {
            object resultMedian = null;
            matlab.Feval("median", 1, out resultMedian, partialSpatialScore);

            object[] resultMedianArray = resultMedian as object[];

            median = (Double)resultMedianArray[0];

            return median;
        }

        public void calculatePartialSpatialScore()
        {
            Double[] tmp = new Double[numSAUs];
            for(int i = 0; i < numSAUs; i++)
            {
                tmp[i] = spatialScore[id_ref, i];
            }

            partialSpatialScore = tmp;
            Console.WriteLine("Awesome...");
        }

        public void findSkeletonTIndices()
        {
            for(int i = 0; i < partialSpatialScore.Length; i++)
            {
                if(partialSpatialScore[i] < median)
                {
                    SkeletonTIndices.Add(i);
                }
            }
        }

        public void findSkeletonR()
        {
            foreach (int i in SkeletonTIndices)
            {
                SkeletonInlier.Add(SkeletonT[i]);
            }

            object[] SpatialSumParams = new object[SkeletonInlier.Count];
            for (int i = 0; i < SkeletonInlier.Count; i++)
            {
                SpatialSumParams[i] = SkeletonInlier[i];
            }


            object resultSpatialSum = null;
            matlab.Feval("SpatialSum", 1, out resultSpatialSum, SpatialSumParams, 0.1);

            object[] resultSpatialSumArray = resultSpatialSum as object[];

            SkeletonR = (Double[,])resultSpatialSumArray[0];
        }

        // Getters
        public Double[,] getSkeletonR() { return SkeletonR; }

        MLApp.MLApp matlab;
        int id_ref;
        Double[,] spatialScore;
        Double[,] SkeletonR;
        List<Double[,]> SkeletonT;
        List<int> SkeletonTIndices;
        Double median;
        int numSAUs;
        Double[] partialSpatialScore;
        List<Double[,]> SkeletonInlier;
    }
}