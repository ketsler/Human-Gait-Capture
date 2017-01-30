using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    class TASSDriver
    {

        public TASSDriver(String POCMCODE_location)
        {
            client = new MatlabHandler(POCMCODE_location);
            skeleton = new SkeletonHandler();
            segmentation = new Segmentation(client.getMatlab());
            spatialAlignment = new SpatialAlignment(client.getMatlab());
            referenceSAUHandler = null;
            temporalAlignment = null;
            spatialSummarization = null;
            featuresHandler = null;

        }

        // Load a Skeleton
        public void loadSkeleton(String filename)
        {
            skeleton.loadFile(filename);
            skeleton.formatToTASS();
            skeleton.convertToArray();
        }

        // Perform the Segmentation
        public void performSegmentation()
        {
            segmentation.Execute(skeleton.getArray());
            segmentation.typeTheRawData();
        }

        public void performSpatialAlignment()
        {
            spatialAlignment.Execute(segmentation.getSAUs());
            spatialAlignment.typeTheRawData();
        }

        public void findReferenceSAUs()
        {
            // Find all reference SAU's 
            referenceSAUHandler = new ReferenceSAUHandler(client.getMatlab(), segmentation.getNumSAUs());
            referenceSAUHandler.Execute(spatialAlignment.getAlignedSAUs());
        }

        public void performTemporalAlignment()
        {
            // Temporal Alignment
            temporalAlignment = new TemporalAlignment(client.getMatlab(), referenceSAUHandler.getNumSAUs(), referenceSAUHandler.getIdRef());
            temporalAlignment.Execute(spatialAlignment.getAlignedSAUs());

        }

        public void performSpatialSummarization()
        {
            spatialSummarization = new SpatialSummarization(client.getMatlab(), referenceSAUHandler.getSpatialScore(), referenceSAUHandler.getIdRef(), temporalAlignment.getSkeletonT(), referenceSAUHandler.getNumSAUs());
            spatialSummarization.Execute();
        }

        public List<double> findAllFeatures()
        {
            //featuresHandler = new FeaturesHandler(client.getMatlab(), spatialSummarization.getSkeletonR());
            featuresHandler = new FeaturesHandler(client.getMatlab(), temporalAlignment.getSkeletonT()[0]);
            return featuresHandler.Execute();
        }

        public List<double> Execute() {

            client.getMatlab().Execute("clear");

            // Load the skeleton - NOTE THIS WILL CHANGE TO LOADING LISTS FROM MEMORY
            // THIS IS JUST TO GET IT ALL TO WORK
            loadSkeleton(@"C:\done\Training\siddhantTraining2.txt");

            // Perform the segmentation
            performSegmentation();

            // Spatial Alignment
            performSpatialAlignment();

            // Find Reference SAUs
            findReferenceSAUs();

            // Perform temporal alignment
            performTemporalAlignment();

            // Perform Spatial Summarization
            //performSpatialSummarization();

            // Find features
            return findAllFeatures();

        }

        MatlabHandler client;
        SkeletonHandler skeleton;
        Segmentation segmentation;
        SpatialAlignment spatialAlignment;
        ReferenceSAUHandler referenceSAUHandler;
        TemporalAlignment temporalAlignment;
        SpatialSummarization spatialSummarization;
        FeaturesHandler featuresHandler;
        
    }
}
