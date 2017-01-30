using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Globalization;
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
using System.Windows.Shapes;
using System.Xml;
using Microsoft.Kinect;
using TASS;
using WinForms = System.Windows.Forms;

namespace GaitID
{
    /// <summary>
    /// Interaction logic for Capture.xaml
    /// </summary>
    public partial class Capture : Window, INotifyPropertyChanged
    {

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
        /// Bitmap for storing color image
        /// </summary>
        private WriteableBitmap colorBitmap = null;

        /// <summary>
        /// Coordinate mapper to map one type of point to another
        /// </summary>
        private CoordinateMapper coordinateMapper = null;

        /// <summary>
        /// Reader for body frames
        /// </summary>
        private MultiSourceFrameReader multiSourceFrameReader = null;

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

        private List<JointType> tassJoints = null;

        // Variables for capturing video
        private int imageNum;
        private bool videoCapture;
        private BitmapEncoder encoder;

        // Variables for saving files
        private string fileSaveLocation;
        private string skeletonFileName;
        private string fullSkeletonFilePath;

        // Database variables
        DatabaseHandler db = new DatabaseHandler();
        private int subjectID;

        private List<Double> featuresList;
        private string[] jointList = new string[] { "Head", "Shoulder-Center", "Shoulder-Right", "Shoulder-Left",
                                            "Elbow-Right", "Elbow-Left", "Wrist-Right", "Wrist-Left",
                                            "Hand-Right", "Hand-Left", "Spine", "Hip-Center", "Hip-Right",
                                            "Hip-Left", "Knee-Right", "Knee-Left", "Ankle-Right", "Ankle-Left",
                                            "Foot-Right", "Foot-Left"};


        public Capture()
        {
            imageNum = 0;
            videoCapture = false;

            // one sensor is currently supported
            this.kinectSensor = KinectSensor.GetDefault();

            // BODY CAPTURE

            // get the coordinate mapper
            this.coordinateMapper = this.kinectSensor.CoordinateMapper;

            // get the depth (display) extents
            FrameDescription frameDescription = this.kinectSensor.DepthFrameSource.FrameDescription;

            // create the colorFrameDescription from the ColorFrameSource using Bgra format
            FrameDescription colorFrameDescription = this.kinectSensor.ColorFrameSource.CreateFrameDescription(ColorImageFormat.Bgra);

            // create the bitmap to display
            this.colorBitmap = new WriteableBitmap(colorFrameDescription.Width, colorFrameDescription.Height, 96.0, 96.0, PixelFormats.Bgr32, null);

            // get size of joint space
            this.displayWidth = frameDescription.Width;
            this.displayHeight = frameDescription.Height;

            // open the reader for the body and color frames
            this.multiSourceFrameReader = this.kinectSensor.OpenMultiSourceFrameReader(FrameSourceTypes.Body|
                FrameSourceTypes.Color);
            

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
            this.tassJoints = new List<JointType>();
            this.tassJoints.Add(JointType.Head);
            this.tassJoints.Add(JointType.SpineShoulder);
            this.tassJoints.Add(JointType.ShoulderRight);
            this.tassJoints.Add(JointType.ShoulderLeft);
            this.tassJoints.Add(JointType.ElbowRight);
            this.tassJoints.Add(JointType.ElbowLeft);
            this.tassJoints.Add(JointType.WristRight);
            this.tassJoints.Add(JointType.WristLeft);
            this.tassJoints.Add(JointType.HandRight);
            this.tassJoints.Add(JointType.HandLeft);
            this.tassJoints.Add(JointType.SpineMid);
            this.tassJoints.Add(JointType.SpineBase);
            this.tassJoints.Add(JointType.HipRight);
            this.tassJoints.Add(JointType.HipLeft);
            this.tassJoints.Add(JointType.KneeRight);
            this.tassJoints.Add(JointType.KneeLeft);
            this.tassJoints.Add(JointType.AnkleRight);
            this.tassJoints.Add(JointType.AnkleLeft);
            this.tassJoints.Add(JointType.FootRight);
            this.tassJoints.Add(JointType.FootLeft);


            // populate body colors, one for each BodyIndex
            this.bodyColors = new List<Pen>();

            this.bodyColors.Add(new Pen(Brushes.Red, 6));
            this.bodyColors.Add(new Pen(Brushes.Orange, 6));
            this.bodyColors.Add(new Pen(Brushes.Green, 6));
            this.bodyColors.Add(new Pen(Brushes.Blue, 6));
            this.bodyColors.Add(new Pen(Brushes.Indigo, 6));
            this.bodyColors.Add(new Pen(Brushes.Violet, 6));
            
            // open the sensor
            this.kinectSensor.Open();
            
            // set IsAvailableChanged event notifier
            this.kinectSensor.IsAvailableChanged += this.Sensor_IsAvailableChanged;

            // set the status text
            this.StatusText = this.kinectSensor.IsAvailable ? Properties.Resources.RunningStatusText
                                                            : Properties.Resources.NoSensorStatusText;

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

        /// <summary>
        /// INotifyPropertyChangedPropertyChanged event to allow window controls to bind to changeable data
        /// </summary>
        public event PropertyChangedEventHandler PropertyChanged;

        /// <summary>
        /// Gets the skeletal bitmap to display
        /// </summary>
        public ImageSource ImageSource
        {
            get
            {
                return this.imageSource;
            }
        }

        /// <summary>
        /// Gets the color bitmap to display
        /// </summary>
        public ImageSource ColorImageSource
        {
            get
            {
                return this.colorBitmap;
            }
        }

        /// <summary>
        /// Gets or sets the current status text to display
        /// </summary>
        public string StatusText
        {
            get
            {
                return this.statusText;
            }

            set
            {
                if (this.statusText != value)
                {
                    this.statusText = value;

                    // notify any bound elements that the text has changed
                    if (this.PropertyChanged != null)
                    {
                        this.PropertyChanged(this, new PropertyChangedEventArgs("StatusText"));
                    }
                }
            }
        }

        /// <summary>
        /// Execute start up tasks
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Capture_OnLoaded(object sender, RoutedEventArgs e)
        {
            if (this.kinectSensor != null)
            {
                this.kinectSensor.Open();
            }

            if (this.multiSourceFrameReader != null)
            {
                this.multiSourceFrameReader.MultiSourceFrameArrived += this.Reader_MultiSourceFrameArrived;
            }
        }

        /// <summary>
        /// Execute shutdown tasks
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Capture_OnClosing(object sender, CancelEventArgs e)
        {
            if (this.multiSourceFrameReader != null)
            {
                // BodyFrameReader is IDisposable
                this.multiSourceFrameReader.Dispose();
                this.multiSourceFrameReader = null;
            }

            if (this.kinectSensor != null)
            {
                this.kinectSensor.Close();
                this.kinectSensor = null;
            }
        }

        /// <summary>
        /// Handles the multi source frame data arriving from the sensor
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Reader_MultiSourceFrameArrived(object sender, MultiSourceFrameArrivedEventArgs e)
        {
            bool dataReceived = false;

            using (BodyFrame bodyFrame = e.FrameReference.AcquireFrame().BodyFrameReference.AcquireFrame()) 
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
                            int jointCount = 0;
                            foreach (JointType joint in tassJoints)
                            {
                                if (joints[joint].Position.Z == 0) break;

                                String tmp = "";
                                tmp += jointList[jointCount]+";"+joints[joint].Position.X;
                                tmp += ";" + joints[joint].Position.Y;
                                tmp += ";" + (joints[joint].Position.Z) + "\r\n";

                                tmpFrame += tmp;

                                ++jointCount;

                            }

                            stringFrames.Add(tmpFrame);
                        }
                    }

                    // prevent drawing outside of our render area
                    this.drawingGroup.ClipGeometry = new RectangleGeometry(new Rect(0.0, 0.0, this.displayWidth, this.displayHeight));
                }

                // Display color stream
                using (ColorFrame colorFrame = e.FrameReference.AcquireFrame().ColorFrameReference.AcquireFrame())
                {
                    if (colorFrame != null)
                    {
                        FrameDescription colorFrameDescription = colorFrame.FrameDescription;

                        using (KinectBuffer colorBuffer = colorFrame.LockRawImageBuffer())
                        {
                            this.colorBitmap.Lock();

                            // verify data and write the new color frame data to the display bitmap
                            if ((colorFrameDescription.Width == this.colorBitmap.PixelWidth) && (colorFrameDescription.Height == this.colorBitmap.PixelHeight))
                            {
                                colorFrame.CopyConvertedFrameDataToIntPtr(
                                    this.colorBitmap.BackBuffer,
                                    (uint)(colorFrameDescription.Width * colorFrameDescription.Height * 4),
                                    ColorImageFormat.Bgra);

                                this.colorBitmap.AddDirtyRect(new Int32Rect(0, 0, this.colorBitmap.PixelWidth, this.colorBitmap.PixelHeight));
                            }

                            this.colorBitmap.Unlock();
                        }
                        if (videoCapture)
                        {
                            captureImage();
                        }
                    }
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
            if (this.kinectSensor != null)
            {
                this.StatusText = this.kinectSensor.IsAvailable
                    ? Properties.Resources.RunningStatusText
                    : Properties.Resources.NoSensorStatusText;
            }
        }

        //Generate random number of fixed length (will be 10), for anonymous person ID
        private string RandomDigits(int length)
        {
            var random = new Random();
            string s = string.Empty;
            for (int i = 0; i < length; i++)
                s = String.Concat(s, random.Next(10).ToString());
            return s;
        }

        /// <summary>
        /// Run the TASS (Temporal Alignment and Spectral Summary) with the generated input file
        /// </summary>
        /// ORIGINAL GENERATE DATA FILE CODE IS COMMENTED OUT-KYLE ETSLER 10/31/2016
        /*public void generateSkeletalDataFile()
        {
            skeletonFileName = "skeleton.txt";
            skeletonFileName = AppendTimeStamp(skeletonFileName);
            fullSkeletonFilePath = System.IO.Path.Combine(fileSaveLocation, skeletonFileName);

            try
            {
                StreamWriter output = new StreamWriter(System.IO.Path.Combine(fileSaveLocation, skeletonFileName));

                int count = 1;
                int stringCount = 1;

                output.WriteLine("Microsoft Kinect SDK"); // String of what we are using to extract the skeletal data
                output.WriteLine((savedFrames.Count - 2).ToString()); // Number of frames in the recording
                output.WriteLine(15.ToString()); // Number of Joints which are processed

                //foreach (String s in savedFrames)
                for (int i = 1; i < savedFrames.Count - 1; i++)
                {
                    ++stringCount;

                    //if (count == savedFrames.Count || stringCount == savedFrames.Count)
                    //   break;
                    output.WriteLine(count.ToString());
                    output.WriteLine(1.ToString()); // Simply denotes which body is going to be used. It's always 1 
                    output.Write(savedFrames[i]);
                    //Console.WriteLine(savedFrames[i]);
                    ++count;
                }
                output.Close();
                // this.statusText = Properties.Resources.FinishedWritingDataStatusText;  why doesn't this work?
                //MessageBox.Show("Finished writing data to file", "Data Capture");
            }
            catch (UnauthorizedAccessException)
            {
                //this.StatusText = Properties.Resources.FileSaveLocationError;
                MessageBox.Show("Error writing data file. Make sure location is not Read-Only.",
                    "File Write Error", MessageBoxButton.OK, MessageBoxImage.Error);

            }
        }*/

        public void generateSkeletalDataFile()
        {
            skeletonFileName = "skeleton.txt";
            skeletonFileName = AppendTimeStamp(skeletonFileName);
            if(NameEntryBox.Text == "")
            {
                fullSkeletonFilePath = System.IO.Path.Combine(fileSaveLocation, skeletonFileName);
            }
            else
            {
                skeletonFileName = skeletonFileName.Insert(0, NameEntryBox.Text + "-");
            }

            try
            {
                StreamWriter output = new StreamWriter(System.IO.Path.Combine(fileSaveLocation, skeletonFileName));

                int count = 1;
                int stringCount = 1;
                int jointCount = 0;


                //foreach (String s in savedFrames)
                for (int i = 1; i < savedFrames.Count - 1; i++)
                {
                    ++stringCount;
                    output.Write(savedFrames[i]);
                    ++count;
                    ++jointCount;
                }
                output.Close();
                // this.statusText = Properties.Resources.FinishedWritingDataStatusText;  why doesn't this work?
                //MessageBox.Show("Finished writing data to file", "Data Capture");
            }
            catch (UnauthorizedAccessException)
            {
                //this.StatusText = Properties.Resources.FileSaveLocationError;
                MessageBox.Show("Error writing data file. Make sure location is not Read-Only.",
                    "File Write Error", MessageBoxButton.OK, MessageBoxImage.Error);

            }
        }

        private void captureImage()
        {
            if (this.colorBitmap != null)
            {
                // create a png bitmap encoder which knows how to save a .png file
                encoder = new JpegBitmapEncoder();

                // create frame from the writable bitmap and add to encoder
                encoder.Frames.Add(BitmapFrame.Create(this.colorBitmap));

                //string myPhotos = Environment.GetFolderPath(Environment.SpecialFolder.MyPictures);
                //string imagePath = System.IO.Path.Combine(myPhotos, "kinect\\" + (imageNum++) + ".jpg");
            }
        }

        // Delete all images currently in MyPictures/kinect directory
        private void cleanImageDirectory()
        {
            string myPhotos = Environment.GetFolderPath(Environment.SpecialFolder.MyPictures);
            string path = System.IO.Path.Combine(myPhotos, "kinect");
            System.IO.DirectoryInfo di = new DirectoryInfo(path);

            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }
        }

        private void generateImageFile()
        {
            // write the image to disk

            //String filename = "image.jpg";
            //filename = AppendTimeStamp(filename);

            String filename = subjectID.ToString() + ".jpg";

            try
            {
                // FileStream is IDisposable
                using (
                    FileStream fs = new FileStream(System.IO.Path.Combine(fileSaveLocation, filename),
                        FileMode.Create))
                {
                    encoder.Save(fs);
                }

            }
            catch (UnauthorizedAccessException)
            {
                MessageBox.Show("Error saving image file. Make sure location is not Read-Only.",
                    "File Write Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void generateVideoFile()
        {
            string myPhotos = Environment.GetFolderPath(Environment.SpecialFolder.MyPictures);

            string path = System.IO.Path.Combine(myPhotos, "kinect");
            string ffmpegPath = @"H:\ffmpeg.exe";

            Process.Start(ffmpegPath,
                "-framerate 15 -i H:\\andyj_000\\Pictures\\kinect\\%d.jpg -c:v libx264 -r 30 -pix_fmt yuv420p H:\\kinect_video.mp4");
        }


        private void RecordButton_Click(object sender, RoutedEventArgs e)
        {
            stringFrames.Clear();
            cleanImageDirectory();
            recordingLabel.Visibility = Visibility.Visible;
            //videoCapture = true;
            //captureImage();
        }

        private void StopButton_Click(object sender, RoutedEventArgs e)
        {
            //this.kinectSensor.Close();
            savedFrames = stringFrames;
            recordingLabel.Visibility = Visibility.Hidden;
            videoCapture = false;
            imageNum = 0;
            captureImage();

            //generateVideoFile();
        }


        private void StoreButton_OnClick(object sender, RoutedEventArgs e)
        {
            // Check to see save location has been selected
            if (FileSaveLocationTextBox.Text == "")
            {
                chooseNewFileSaveLocation();
            }

            generateSkeletalDataFile();
            //generateAndStoreFeatures();
           // generateImageFile(); // Do this last so we can change the name to the subject's ID for easy retrieval
        }


        private void generateAndStoreFeatures()
        {

            // run tass and save features to DB
             TASSDriver tass = new TASSDriver(@"C:\temp\POCM CODE");

            // Busy wait until skeletal data is finished writing
            while (!File.Exists(fullSkeletonFilePath)) ;

            tass.loadSkeleton(fullSkeletonFilePath);

            featuresList = new List<double>(tass.Execute());

            // Insert data into data store
            db.GetAllData();

            if (db.GetRawData() == null)
                subjectID = 0;
            else
                subjectID = db.Count();

            String name = NameEntryBox.Text;

            db.Insert(subjectID, name, featuresList);



            MessageBox.Show("Finished writing features to database", "Data Capture");
        }


        private void BrowseButton_OnClick(object sender, RoutedEventArgs e)
        {
            chooseFileSaveLocation();
        }


        private void chooseFileSaveLocation()
        {
            // Open file browser dialog
            var dialog = new WinForms.FolderBrowserDialog();
            dialog.Description = "Select where to save skeletal data file:";
            WinForms.DialogResult result = dialog.ShowDialog();
            fileSaveLocation = dialog.SelectedPath;
            FileSaveLocationTextBox.Text = fileSaveLocation;
            string tempIDNum = new FileInfo(fileSaveLocation).Name;
            IDEntryBox.Text = tempIDNum;
        }
        

        private void chooseNewFileSaveLocation()
        {
            bool foldercheck = false;
            string topFolder = (@"C:\Users\Kyle\Desktop\GAIT\Data\");
            do
            {
                string tempIDNum = RandomDigits(10);
                if (!Directory.Exists(topFolder + tempIDNum))
                {
                    Directory.CreateDirectory(topFolder + tempIDNum);
                    fileSaveLocation = System.IO.Path.Combine(topFolder, tempIDNum);
                    IDEntryBox.Text = tempIDNum;
                    foldercheck = true;
                    FileSaveLocationTextBox.Text = fileSaveLocation;
                }

            } while (foldercheck == false);
        }

        public string AppendTimeStamp(string fileName)
        {
            return string.Concat(
                System.IO.Path.GetFileNameWithoutExtension(fileName),
                "_",
                DateTime.Now.ToString("yyyyMMddHHmmssfff"),
                System.IO.Path.GetExtension(fileName)
                );
        }

        private void FeatureNavButton_OnClick(object sender, RoutedEventArgs e)
        {
            FeatureID featureWin = new FeatureID();
            featureWin.Show();
            this.Close();
        }

        private void TestBenchButton_OnClick(object sender, RoutedEventArgs e)
        {
            TestBench featureWin = new GaitID.TestBench();
            featureWin.Show();
            this.Close();
        }

        private void IdentifyButton_OnClick(object sender, RoutedEventArgs e)
        {
            // Check to see save location has been selected
            if (FileSaveLocationTextBox.Text == "")
            {
                chooseNewFileSaveLocation();
            }

            generateSkeletalDataFile();

            // Run TASS, classifier, output name
            TASSDriver tass = new TASSDriver(@"C:\temp\POCM CODE");

            // Busy wait until skeletal data is finished writing
            while (!File.Exists(fullSkeletonFilePath)) ;

            tass.loadSkeleton(fullSkeletonFilePath);

            featuresList = new List<double>(tass.Execute());

            Classifier();
        }

        // Simple classifier which takes pre-processed data and compares it
        private void Classifier()
        {

            db.GetAllData();
            List<List<double>> dblList = db.GetFeatures();

            //db.printLists();

            var diffList = new List<double> { };

            foreach (List<double> l in dblList)
            {
                diffList.Add(EuclidDist(featuresList, l));
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


            Console.WriteLine("MinIndex = " + minIndex);
            DataSet identifiedDataSet = db.GetRow(minIndex);
            String name = identifiedDataSet.Tables["Features"].Rows[0][0].ToString();

            MessageBox.Show("Subject identified as: " + name, "Subject Identification");

            //Debug.Write(minIndex);
            //MessageBox.Show("Subject identified as: " + minIndex.ToString());

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
        }

        private double EuclidDist(List<double> x, List<double> y)
        {
            double sum = 0;

            for (var i = 0; i < 6; i++)
            {
                sum += (x[i] - y[i]) * (x[i] - y[i]);
            }

            return Math.Sqrt(sum);
    
        }

        /// <summary>
        /// Returns the length of a vector from origin
        /// </summary>
        /// <param name="point">Point in space to find it's distance from origin</param>
        /// <returns>Distance from origin</returns>
        private static double VectorLength(CameraSpacePoint point)
        {
            var result = Math.Pow(point.X, 2) + Math.Pow(point.Y, 2) + Math.Pow(point.Z, 2);

            result = Math.Sqrt(result);

            return result;
        }



        /// <summary>
        /// Finds the closest body from the sensor if any
        /// </summary>
        /// <param name="bodyFrame">A body frame</param>
        /// <returns>Closest body, null of none</returns>
        private static Body FindClosestBody(BodyFrame bodyFrame)
        {
            Body result = null;
            double closestBodyDistance = double.MaxValue;

            Body[] bodies = new Body[bodyFrame.BodyCount];
            bodyFrame.GetAndRefreshBodyData(bodies);

            foreach (var body in bodies)
            {
                if (body.IsTracked)
                {
                    var currentLocation = body.Joints[JointType.SpineBase].Position;

                    var currentDistance = VectorLength(currentLocation);

                    if (result == null || currentDistance < closestBodyDistance)
                    {
                        result = body;
                        closestBodyDistance = currentDistance;
                    }
                }
            }

            return result;
        }


    }



}