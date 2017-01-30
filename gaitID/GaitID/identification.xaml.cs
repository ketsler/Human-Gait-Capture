using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using Microsoft.Kinect;


namespace GaitID
{
    /// <summary>
    /// Interaction logic for Identification.xaml
    /// </summary>
    public partial class Identification : Window, INotifyPropertyChanged
    {
        // Setup database handler
        DatabaseHandler db = new DatabaseHandler();


        /// <summary>
        /// Radius of drawn hand circles
        /// </summary>
        private const double HandSize = 30;

        /// <summary>
        /// Thickness of drawn joint lines
        /// </summary>
        private const double JointThickness = 3;

        /// <summary>
        /// Thickness of clip edge rectangles
        /// </summary>
        private const double ClipBoundsThickness = 10;

        /// <summary>
        /// Constant for clamping Z values of camera space points from being negative
        /// </summary>
        private const float InferredZPositionClamp = 0.1f;

        /// <summary>
        /// Brush used for drawing hands that are currently tracked as closed
        /// </summary>
        private readonly Brush handClosedBrush = new SolidColorBrush(Color.FromArgb(128, 255, 0, 0));

        /// <summary>
        /// Brush used for drawing hands that are currently tracked as opened
        /// </summary>
        private readonly Brush handOpenBrush = new SolidColorBrush(Color.FromArgb(128, 0, 255, 0));

        /// <summary>
        /// Brush used for drawing hands that are currently tracked as in lasso (pointer) position
        /// </summary>
        private readonly Brush handLassoBrush = new SolidColorBrush(Color.FromArgb(128, 0, 0, 255));

        /// <summary>
        /// Brush used for drawing joints that are currently tracked
        /// </summary>
        private readonly Brush trackedJointBrush = new SolidColorBrush(Color.FromArgb(255, 68, 192, 68));

        /// <summary>
        /// Brush used for drawing joints that are currently inferred
        /// </summary>        
        private readonly Brush inferredJointBrush = Brushes.Yellow;

        /// <summary>
        /// Pen used for drawing bones that are currently inferred
        /// </summary>        
        private readonly Pen inferredBonePen = new Pen(Brushes.Gray, 1);

        /// <summary>
        /// Drawing group for body rendering output
        /// </summary>
        private DrawingGroup drawingGroup;

        /// <summary>
        /// Drawing image that we will display
        /// </summary>
        private DrawingImage imageSource;

        /// <summary>
        /// Active Kinect sensor
        /// </summary>
        private KinectSensor kinectSensor = null;

        /// <summary>
        /// Coordinate mapper to map one type of point to another
        /// </summary>
        private CoordinateMapper coordinateMapper = null;

        /// <summary>
        /// Reader for body frames
        /// </summary>
        private BodyFrameReader bodyFrameReader = null;

        /// <summary>
        /// Array for the bodies
        /// </summary>
        private Body[] bodies = null;

        /// <summary>
        /// definition of bones
        /// </summary>
        private List<Tuple<JointType, JointType>> bones;

        /// <summary>
        /// Width of display (depth space)
        /// </summary>
        private int displayWidth;

        /// <summary>
        /// Height of display (depth space)
        /// </summary>
        private int displayHeight;

        /// <summary>
        /// List of colors for each body tracked
        /// </summary>
        private List<Pen> bodyColors;

        /// <summary>
        /// Current status text to display
        /// </summary>
        private string statusText = null;

        /// <summary>
        /// List of all of the frames in string form. It will be in the form of a list so
        /// as to be able to allow us to easily generate the output file for the skeletal data.
        /// </summary>
        private List<string> stringFrames = null;
        private List<string> savedFrames = null;

        /// <summary>
        /// List of all of the frames in string form. It will be in the form of a list so
        /// as to be able to allow us to easily generate the output file for the skeletal data.
        /// </summary>
        private List<JointType> tassJoints = null;

        private List<double> testData = null;

        public Identification()
        {
            Console.WriteLine("IN IDENTIFICATION CONSTRUCTOR");

            this.tassJoints = new List<JointType>();

            // one sensor is currently supported
            this.kinectSensor = KinectSensor.GetDefault();

            // get the coordinate mapper
            this.coordinateMapper = this.kinectSensor.CoordinateMapper;

            // get the depth (display) extents
            FrameDescription frameDescription = this.kinectSensor.DepthFrameSource.FrameDescription;

            // get size of joint space
            this.displayWidth = frameDescription.Width;
            this.displayHeight = frameDescription.Height;

            // open the reader for the body frames
            this.bodyFrameReader = this.kinectSensor.BodyFrameSource.OpenReader();

            // a bone defined as a line between two joints
            this.bones = new List<Tuple<JointType, JointType>>();

            // Torso
            this.bones.Add(new Tuple<JointType, JointType>(JointType.Head, JointType.Neck));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.Neck, JointType.SpineShoulder));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.SpineShoulder, JointType.SpineMid));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.SpineMid, JointType.SpineBase));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.SpineShoulder, JointType.ShoulderRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.SpineShoulder, JointType.ShoulderLeft));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.SpineBase, JointType.HipRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.SpineBase, JointType.HipLeft));

            // Right Arm
            this.bones.Add(new Tuple<JointType, JointType>(JointType.ShoulderRight, JointType.ElbowRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.ElbowRight, JointType.WristRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.WristRight, JointType.HandRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.HandRight, JointType.HandTipRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.WristRight, JointType.ThumbRight));

            // Left Arm
            this.bones.Add(new Tuple<JointType, JointType>(JointType.ShoulderLeft, JointType.ElbowLeft));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.ElbowLeft, JointType.WristLeft));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.WristLeft, JointType.HandLeft));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.HandLeft, JointType.HandTipLeft));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.WristLeft, JointType.ThumbLeft));

            // Right Leg
            this.bones.Add(new Tuple<JointType, JointType>(JointType.HipRight, JointType.KneeRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.KneeRight, JointType.AnkleRight));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.AnkleRight, JointType.FootRight));

            // Left Leg
            this.bones.Add(new Tuple<JointType, JointType>(JointType.HipLeft, JointType.KneeLeft));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.KneeLeft, JointType.AnkleLeft));
            this.bones.Add(new Tuple<JointType, JointType>(JointType.AnkleLeft, JointType.FootLeft));

            // Populate the joint list with the joint data we wish to extract
            // This is only going to take the data from the following 15 joints
            this.tassJoints.Add(JointType.SpineMid);
            this.tassJoints.Add(JointType.SpineShoulder);
            this.tassJoints.Add(JointType.Head);
            this.tassJoints.Add(JointType.ShoulderLeft);
            this.tassJoints.Add(JointType.ElbowLeft);
            this.tassJoints.Add(JointType.WristLeft);
            this.tassJoints.Add(JointType.ShoulderRight);
            this.tassJoints.Add(JointType.ElbowRight);
            this.tassJoints.Add(JointType.WristRight);
            this.tassJoints.Add(JointType.HipLeft);
            this.tassJoints.Add(JointType.KneeLeft);
            this.tassJoints.Add(JointType.AnkleLeft);
            this.tassJoints.Add(JointType.HipRight);
            this.tassJoints.Add(JointType.KneeRight);
            this.tassJoints.Add(JointType.AnkleRight);

            // populate body colors, one for each BodyIndex
            this.bodyColors = new List<Pen>();

            this.bodyColors.Add(new Pen(Brushes.Red, 6));
            this.bodyColors.Add(new Pen(Brushes.Orange, 6));
            this.bodyColors.Add(new Pen(Brushes.Green, 6));
            this.bodyColors.Add(new Pen(Brushes.Blue, 6));
            this.bodyColors.Add(new Pen(Brushes.Indigo, 6));
            this.bodyColors.Add(new Pen(Brushes.Violet, 6));

            // set IsAvailableChanged event notifier
            //this.kinectSensor.IsAvailableChanged += this.Sensor_IsAvailableChanged;

            // open the sensor
            this.kinectSensor.Open();

            // set the status text
            //this.StatusText = this.kinectSensor.IsAvailable ? Properties.Resources.RunningStatusText
            //                                                : Properties.Resources.NoSensorStatusText;

            // Create the drawing group we'll use for drawing
            this.drawingGroup = new DrawingGroup();

            // Create an image source that we can use in our image control
            this.imageSource = new DrawingImage(this.drawingGroup);

            // use the window object as the view model in this simple example
            this.DataContext = this;

            // Initialize the stringFrames to an empty set
            this.stringFrames = new List<string>();
            this.savedFrames = new List<string>();



            // initialize the components (controls) of the window
            this.InitializeComponent();
        }

        private void backButton_Click(object sender, RoutedEventArgs e)
        {
            MainWindow mainWin = new MainWindow();
            mainWin.Show();
            this.Close();
        }

        private void trainingButton_Click(object sender, RoutedEventArgs e)
        {
            Training trainingWin = new Training();
            trainingWin.Show();
            this.Close();
        }

        private void comparisonButton_Click(object sender, RoutedEventArgs e)
        {
            comparison compareWin = new comparison();
            compareWin.Show();
            this.Close();
        }

        private void identifyButton_Click(object sender, RoutedEventArgs e)
        {
            
            string outPath = @"C:\temp\POCM CODE\Skeletal Data\skeleton.txt";
            string tassPath = @"C:\temp\POCM CODE\Generated Data\tass-skeleton.txt";

            // Delete temp file if it exists
            if (File.Exists(outPath))
                File.Delete(outPath);

            // Delete temp file if it exists
            if (File.Exists(tassPath))
                File.Delete(tassPath);

            this.GenerateSkeletalDataFile(outPath);

            // Run TASS
            // Create the MATLAB instance 
            //MLApp.MLApp matlab = new MLApp.MLApp();
            // Change to the directory where the function is located 
            //matlab.Execute(@"cd 'C:\temp\POCM CODE'");




            // Retrieve processed TASS data
            string line;
            System.IO.StreamReader file = new System.IO.StreamReader(tassPath);
            line = file.ReadLine();
            testData = line.Split(',').Select(double.Parse).ToList();

            //Send skeleton through classifier and return match from database
            Classifier();

            // Reopen sensor
            this.kinectSensor.Open();
        }
    

        /// <summary>
        /// INotifyPropertyChangedPropertyChanged event to allow window controls to bind to changeable data
        /// </summary>
        public event PropertyChangedEventHandler PropertyChanged;

        /// <summary>
        /// Gets the bitmap to display
        /// </summary>
        public ImageSource ImageSource
        {
            get
            {
                return this.imageSource;
            }
        }

        /// <summary>
        /// Gets or sets the current status text to display
        /// </summary>
        //public string StatusText
        //{
        //    get
        //    {
        //        return this.statusText;
        //    }

        //    set
        //    {
        //        if (this.statusText != value)
        //        {
        //            this.statusText = value;

        //            // notify any bound elements that the text has changed
        //            if (this.PropertyChanged != null)
        //            {
        //                this.PropertyChanged(this, new PropertyChangedEventArgs("StatusText"));
        //            }
        //        }
        //    }
        //}

        /// <summary>
        /// Execute start up tasks
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Identification_Loaded(object sender, RoutedEventArgs e)
        {
            if (this.bodyFrameReader != null)
            {
                this.bodyFrameReader.FrameArrived += this.Reader_FrameArrived;
            }
        }

        /// <summary>
        /// Execute shutdown tasks
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Identification_Closing(object sender, CancelEventArgs e)
        {
            if (this.bodyFrameReader != null)
            {
                // BodyFrameReader is IDisposable
                this.bodyFrameReader.Dispose();
                this.bodyFrameReader = null;
            }

            if (this.kinectSensor != null)
            {
                this.kinectSensor.Close();
                this.kinectSensor = null;
            }
        }

        /// <summary>
        /// Handles the body frame data arriving from the sensor
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Reader_FrameArrived(object sender, BodyFrameArrivedEventArgs e)
        {
            bool dataReceived = false;

            using (BodyFrame bodyFrame = e.FrameReference.AcquireFrame())
            {
                if (bodyFrame != null)
                {
                    if (this.bodies == null)
                    {
                        this.bodies = new Body[bodyFrame.BodyCount];
                    }

                    // The first time GetAndRefreshBodyData is called, Kinect will allocate each Body in the array.
                    // As long as those body objects are not disposed and not set to null in the array,
                    // those body objects will be re-used.
                    bodyFrame.GetAndRefreshBodyData(this.bodies);
                    dataReceived = true;
                }
            }

            if (dataReceived)
            {
                using (DrawingContext dc = this.drawingGroup.Open())
                {
                    // Draw a transparent background to set the render size
                    dc.DrawRectangle(Brushes.Black, null, new Rect(0.0, 0.0, this.displayWidth, this.displayHeight));

                    int penIndex = 0;
                    foreach (Body body in this.bodies)
                    {
                        Pen drawPen = this.bodyColors[penIndex++];

                        if (body.IsTracked)
                        {
                            this.DrawClippedEdges(body, dc);

                            IReadOnlyDictionary<JointType, Joint> joints = body.Joints;

                            // convert the joint points to depth (display) space
                            Dictionary<JointType, Point> jointPoints = new Dictionary<JointType, Point>();

                            foreach (JointType jointType in joints.Keys)
                            {
                                // sometimes the depth(Z) of an inferred joint may show as negative
                                // clamp down to 0.1f to prevent coordinatemapper from returning (-Infinity, -Infinity)
                                CameraSpacePoint position = joints[jointType].Position;
                                if (position.Z < 0)
                                {
                                    position.Z = InferredZPositionClamp;
                                }

                                DepthSpacePoint depthSpacePoint = this.coordinateMapper.MapCameraPointToDepthSpace(position);
                                jointPoints[jointType] = new Point(depthSpacePoint.X, depthSpacePoint.Y);
                            }

                            this.DrawBody(joints, jointPoints, dc, drawPen);

                            this.DrawHand(body.HandLeftState, jointPoints[JointType.HandLeft], dc);
                            this.DrawHand(body.HandRightState, jointPoints[JointType.HandRight], dc);

                            String tmpFrame = "";

                            foreach (JointType joint in tassJoints)
                            {
                                if (joints[joint].Position.Z == 0) break;

                                String tmp = "";
                                tmp += joints[joint].Position.X;
                                tmp += " " + joints[joint].Position.Y;
                                tmp += " " + (joints[joint].Position.Z) + "\r\n";

                                tmpFrame += tmp;


                                // For debugging purposes. Note: Putting any blocking I/O dramatically decreases the framerate
                                // Debug.Write(tmp);
                            }

                            stringFrames.Add(tmpFrame);
                        }
                    }

                    // prevent drawing outside of our render area
                    this.drawingGroup.ClipGeometry = new RectangleGeometry(new Rect(0.0, 0.0, this.displayWidth, this.displayHeight));
                }
            }
        }

        /// <summary>
        /// Draws a body
        /// </summary>
        /// <param name="joints">joints to draw</param>
        /// <param name="jointPoints">translated positions of joints to draw</param>
        /// <param name="drawingContext">drawing context to draw to</param>
        /// <param name="drawingPen">specifies color to draw a specific body</param>
        private void DrawBody(IReadOnlyDictionary<JointType, Joint> joints, IDictionary<JointType, Point> jointPoints, DrawingContext drawingContext, Pen drawingPen)
        {
            // Draw the bones
            foreach (var bone in this.bones)
            {
                this.DrawBone(joints, jointPoints, bone.Item1, bone.Item2, drawingContext, drawingPen);
            }

            // Draw the joints
            foreach (JointType jointType in joints.Keys)
            {
                Brush drawBrush = null;

                TrackingState trackingState = joints[jointType].TrackingState;

                if (trackingState == TrackingState.Tracked)
                {
                    drawBrush = this.trackedJointBrush;
                }
                else if (trackingState == TrackingState.Inferred)
                {
                    drawBrush = this.inferredJointBrush;
                }

                if (drawBrush != null)
                {
                    drawingContext.DrawEllipse(drawBrush, null, jointPoints[jointType], JointThickness, JointThickness);
                }
            }
        }

        /// <summary>
        /// Draws one bone of a body (joint to joint)
        /// </summary>
        /// <param name="joints">joints to draw</param>
        /// <param name="jointPoints">translated positions of joints to draw</param>
        /// <param name="jointType0">first joint of bone to draw</param>
        /// <param name="jointType1">second joint of bone to draw</param>
        /// <param name="drawingContext">drawing context to draw to</param>
        /// /// <param name="drawingPen">specifies color to draw a specific bone</param>
        private void DrawBone(IReadOnlyDictionary<JointType, Joint> joints, IDictionary<JointType, Point> jointPoints, JointType jointType0, JointType jointType1, DrawingContext drawingContext, Pen drawingPen)
        {
            Joint joint0 = joints[jointType0];
            Joint joint1 = joints[jointType1];

            // If we can't find either of these joints, exit
            if (joint0.TrackingState == TrackingState.NotTracked ||
                joint1.TrackingState == TrackingState.NotTracked)
            {
                return;
            }

            // We assume all drawn bones are inferred unless BOTH joints are tracked
            Pen drawPen = this.inferredBonePen;
            if ((joint0.TrackingState == TrackingState.Tracked) && (joint1.TrackingState == TrackingState.Tracked))
            {
                drawPen = drawingPen;
            }

            drawingContext.DrawLine(drawPen, jointPoints[jointType0], jointPoints[jointType1]);
        }

        /// <summary>
        /// Draws a hand symbol if the hand is tracked: red circle = closed, green circle = opened; blue circle = lasso
        /// </summary>
        /// <param name="handState">state of the hand</param>
        /// <param name="handPosition">position of the hand</param>
        /// <param name="drawingContext">drawing context to draw to</param>
        private void DrawHand(HandState handState, Point handPosition, DrawingContext drawingContext)
        {
            switch (handState)
            {
                case HandState.Closed:
                    drawingContext.DrawEllipse(this.handClosedBrush, null, handPosition, HandSize, HandSize);
                    break;

                case HandState.Open:
                    drawingContext.DrawEllipse(this.handOpenBrush, null, handPosition, HandSize, HandSize);
                    break;

                case HandState.Lasso:
                    drawingContext.DrawEllipse(this.handLassoBrush, null, handPosition, HandSize, HandSize);
                    break;
            }
        }

        /// <summary>
        /// Draws indicators to show which edges are clipping body data
        /// </summary>
        /// <param name="body">body to draw clipping information for</param>
        /// <param name="drawingContext">drawing context to draw to</param>
        private void DrawClippedEdges(Body body, DrawingContext drawingContext)
        {
            FrameEdges clippedEdges = body.ClippedEdges;

            if (clippedEdges.HasFlag(FrameEdges.Bottom))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(0, this.displayHeight - ClipBoundsThickness, this.displayWidth, ClipBoundsThickness));
            }

            if (clippedEdges.HasFlag(FrameEdges.Top))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(0, 0, this.displayWidth, ClipBoundsThickness));
            }

            if (clippedEdges.HasFlag(FrameEdges.Left))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(0, 0, ClipBoundsThickness, this.displayHeight));
            }

            if (clippedEdges.HasFlag(FrameEdges.Right))
            {
                drawingContext.DrawRectangle(
                    Brushes.Red,
                    null,
                    new Rect(this.displayWidth - ClipBoundsThickness, 0, ClipBoundsThickness, this.displayHeight));
            }
        }

        /// <summary>
        /// Handles the event which the sensor becomes unavailable (E.g. paused, closed, unplugged).
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Sensor_IsAvailableChanged(object sender, IsAvailableChangedEventArgs e)
        {
            // on failure, set the status text
           // this.StatusText = this.kinectSensor.IsAvailable ? Properties.Resources.RunningStatusText
             //                                               : Properties.Resources.SensorNotAvailableStatusText;
        }

        // Simple classifier which takes pre-processed data and compares it
        private void Classifier()
        {
            //var testData = new List<double> { 0.041999, 0.056030, 1.300000, 0.014929, 0.020966, 0.017302 }; 

            var amanda1 = new List<double> {0.075700, 0.039944, 1.100000, 0.008855, 0.014851, 0.015571};
            var amanda2 = new List<double> {0.077491, 0.039280, 1.400000, 0.010259, 0.011990, 0.025497};
            var anu1 = new List<double> {0.080037, 0.030197, 0.900000, 0.006233, 0.046850, 0.059921};
            var anu2 = new List<double> {0.045856, 0.029655, 1.100000, 0.016933, 0.017145, 0.024118};
            var jeff1 = new List<double> {0.160850, 0.217095, 1.333333, 0.010670, 0.016868, 0.016167};
            var jeff2 = new List<double> {0.117248, 0.110787, 1.200000, 0.013750, 0.021982, 0.006840};
            var mike1 = new List<double> {0.174801, 0.122689, 1.200000, 0.014062, 0.015035, 0.052095};
            var mike2 = new List<double> {0.034700, 0.065779, 1.266667, 0.019390, 0.017602, 0.043389};
            var nicole1 = new List<double> {0.025217, 0.016302, 1.333333, 0.012445, 0.020815, 0.015658};
            var nicole2 = new List<double> {0.028561, 0.044019, 1.400000, 0.010235, 0.009796, 0.020885};
            var peter1 = new List<double> {0.052086, 0.257952, 0.800000, 0.004715, 0.094052, 0.019243};
            var peter2 = new List<double> {0.059063, 0.039369, 1.600000, 0.018843, 0.017619, 0.017964};
            var sunil1 = new List<double> {0.061984, 0.004433, 1.233333, 0.026702, 0.025159, 0.033063};
            var sunil2 = new List<double> {0.022301, 0.107319, 1.133333, 0.020159, 0.019823, 0.024269};

            db.GetAllData();
            List<List<double>> dblList = db.GetFeatures();
            
            var diffList = new List<double> {};

            // Old method
            //diffList.AddRange(dblList.Select(l => EuclidDist(testData, l)));
            //Apparently the line above is the same as the loop below
            foreach (List<Double> l in dblList)
            {
                diffList.Add(EuclidDist(testData, l));
            }

            double min = diffList[0];
            var minIndex = 0;
            for (var i = 0; i < diffList.Count; i++)
            {
                if (diffList[i] < min)
                {
                    min = diffList[i];
                    minIndex = i;
                }
            }

            //Debug.Write(minIndex);
            MessageBox.Show("Min index is: " + minIndex.ToString());

            // Amanda id - amanda1
            // Anu id - mike2
            // Jeff id - jeff2
            // Mike id - jeff2
            // Nicole id - mike1
            // Peter id - peter2
            // Sunil id - jeff2

            // New method
            //int[] minDistIdx = new int[6];
            //double[] minDist = new double[6];
            //for (var i = 0; i < 6; i++)
            //{
            //    minDist[i] = Double.MaxValue;
            //}

            //for (var i = 0; i < bigList.Count; i++)  
            //{
            //    for (var j = 0; j < 6; j++)
            //    {
            //        if (minDist[j] > Math.Abs(bigList[i][j] - testData[j]))
            //        {
            //            minDist[j] = Math.Abs(bigList[i][j] - testData[j]);
            //            minDistIdx[j] = i;
            //        }
            //    }
            //}

            //var query = (from item in minDistIdx
            //             group item by item into g
            //             orderby g.Count() descending
            //             select g.Key).First();

            //Debug.Write(query);

            // With abs
            // Amanda id - peter2
            // Anu id - anu1
            // Jeff id - jeff2
            // Mike id - mike2
            // Nicole id - anu2
            // Peter id - sunil2
            // Sunil id - sunil1

        }

        private double EuclidDist(List<double> x , List<double> y )
        {
            double sum = 0;

            for (var i = 0; i < 6; i++)
            {
                sum += (x[i] - y[i])*(x[i] - y[i]);
            }

            return Math.Sqrt(sum);
        }

        private void GenerateSkeletalDataFile(String filename)
        {
            StreamWriter output = new StreamWriter(filename);
            int count = 1;
            int stringCount = 1;

            output.WriteLine("Microsoft Kinect SDK");                     // String of what we are using to extract the skeletal data
            output.WriteLine((savedFrames.Count - 2).ToString());         // Number of frames in the recording
            output.WriteLine(15.ToString());                              // Number of Joints which are processed

            int savedFramesCount = savedFrames.Count;

            //foreach (String s in savedFrames)
            for (int i = 1; i < savedFrames.Count - 1; i++)
            {
                ++stringCount;

                //if (count == savedFrames.Count || stringCount == savedFrames.Count)
                //   break;
                output.WriteLine(count.ToString());
                output.WriteLine(1.ToString());                     // Simply denotes which body is going to be used. It's always 1 
                output.Write(savedFrames[i]);
                Console.WriteLine(savedFrames[i]);
                ++count;
            }
            output.Close();
            MessageBox.Show("Finished writing data");
        }

        private void recordButton_Click(object sender, RoutedEventArgs e)
        {
            stringFrames.Clear();
            recordingLabel.Visibility = Visibility.Visible;
        }

        private void stopButton_Click(object sender, RoutedEventArgs e)
        {
            this.kinectSensor.Close();
            savedFrames = stringFrames;
            recordingLabel.Visibility = Visibility.Hidden;
        }
    }
}
