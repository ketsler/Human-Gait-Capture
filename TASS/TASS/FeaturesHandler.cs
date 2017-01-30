using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    class FeaturesHandler
    {
        public FeaturesHandler(MLApp.MLApp matlabRef, Double[,] SkeletonR_in)
        {
            matlab = matlabRef;
            SkeletonR = SkeletonR_in;
            newFeatures = null;
            allFeatures = new List<Double>();
        }

        public List<double> Execute()
        {
            StepSize();
            SteppingTime();
            PosturalSwingLevel();
            HandSwingLevel();
            calculateNewFeatures();

            printAllFeatures();

            return allFeatures;
        }

        // Note the template for calculation could be functioned out. However, this gives it
        // more flexibility if we choose to abandon the matlab route.
        public void StepSize()
        {
            object resultStepSize = null;

            matlab.Feval("StepSize", 2, out resultStepSize, SkeletonR);
            object[] resultStepSizeArray = resultStepSize as object[];

            lfStepSize = (Double)resultStepSizeArray[0];
            rfStepSize = (Double)resultStepSizeArray[1];

            allFeatures.Add(lfStepSize);
            allFeatures.Add(rfStepSize);
        }

        public void SteppingTime()
        {
            object resultSteppingTime = null;

            matlab.Feval("steppingTime", 1, out resultSteppingTime, SkeletonR);
            object[] resultSteppingTimeArray = resultSteppingTime as object[];

            steppingTime = (Double)resultSteppingTimeArray[0];

            allFeatures.Add(steppingTime);
        }

        public void PosturalSwingLevel()
        {
            object resultPosturalSwingLevel = null;

            matlab.Feval("posturalSwingLevel", 1, out resultPosturalSwingLevel, SkeletonR);
            object[] resultPosturalSwingLevelArray = resultPosturalSwingLevel as object[];

            posturalSwingLevel = (Double)resultPosturalSwingLevelArray[0];

            allFeatures.Add(posturalSwingLevel);
        }

        public void HandSwingLevel()
        {
            object resultHandSwingLevel = null;

            matlab.Feval("handSwingLevel", 2, out resultHandSwingLevel, SkeletonR);
            object[] resultHandSwingLevelArray = resultHandSwingLevel as object[];

            lHandSwingLevel = (Double)resultHandSwingLevelArray[0];
            rHandSwingLevel = (Double)resultHandSwingLevelArray[1];

            allFeatures.Add(lHandSwingLevel);
            allFeatures.Add(rHandSwingLevel);
        }

        public void calculateNewFeatures()
        {
            object resultNewFeatures = null;

            matlab.Feval("new_features", 1, out resultNewFeatures, SkeletonR);
            object[] resultNewFeaturesArray = resultNewFeatures as object[];

            newFeatures = (Double[,])resultNewFeaturesArray[0];

            foreach(Double d in newFeatures)
            {
                allFeatures.Add(d);
            }
        }

        void printAllFeatures()
        {
            foreach(Double d in allFeatures)
            {
                Console.WriteLine(d.ToString());
            }

        }

        public List<Double> getAllFeatures() { return allFeatures; }

        private MLApp.MLApp matlab;
        private Double[,] SkeletonR;

        // Features
        private Double lfStepSize;
        private Double rfStepSize;
        private Double steppingTime;
        private Double posturalSwingLevel;
        private Double lHandSwingLevel;
        private Double rHandSwingLevel;

        private Double[,] newFeatures;

        // All featuers
        private List<Double> allFeatures;

    }
}
