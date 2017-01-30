using System;
using System.Collections.Generic;
using System.ComponentModel;
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
using Microsoft.Kinect;
using System.Diagnostics;
using System.IO;
using System.Collections.ObjectModel;
using System.Collections;
using System.Data;
using System.Reflection;

namespace GaitID
{
    /// <summary>
    /// Interaction logic for Training.xaml
    /// </summary>
    public partial class Training : Window, INotifyPropertyChanged
    {

        // Setup database handler
        DatabaseHandler db = new DatabaseHandler();

        //
        // DEPTH VARIABLES
        //

        /// <summary>
        /// Map depth range to byte range
        /// </summary>
        private const int MapDepthToByte = 8000 / 256;

        /// <summary>
        /// Reader for depth frames
        /// </summary>
        private DepthFrameReader depthFrameReader = null;

        /// <summary>
        /// Description of the data contained in the depth frame
        /// </summary>
        private FrameDescription depthFrameDescription = null;

        /// <summary>
        /// Bitmap to display
        /// </summary>
        private WriteableBitmap depthBitmap = null;

        /// <summary>
        /// Intermediate storage for frame data converted to color
        /// </summary>
        private byte[] depthPixels = null;

        //
        // BODY VARIABLES
        //

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
        
        // List to hold extracted features from TASS
        private List<double> tassFeatures = null;

        private List<double> testData = null;

        //private MLApp.MLApp matlab = null;

        private string _selectedItem;

        // Collection of name strings for ComboBox
        private ObservableCollection<string> _items = new ObservableCollection<string>() { };

       

        public Training()
        {
            Console.WriteLine("IN TRAINING CONSTRUCTOR");

            // Run TASS
            // Create the MATLAB instance 
            //matlab = new MLApp.MLApp();
            // Change to the directory where the function is located 
            //matlab.Execute(@"cd 'C:\temp\POCM CODE'");


            this.tassJoints = new List<JointType>();
            this.tassFeatures = new List<double>();

            // one sensor is currently supported
            this.kinectSensor = KinectSensor.GetDefault();

            // DEPTH CAPTURE
            
            // open the reader for the depth frames
            this.depthFrameReader = this.kinectSensor.DepthFrameSource.OpenReader();

            // wire handler for frame arrival
            //this.depthFrameReader.FrameArrived += this.Reader_FrameArrived;

            // get FrameDescription from DepthFrameSource
            this.depthFrameDescription = this.kinectSensor.DepthFrameSource.FrameDescription;

            // allocate space to put the pixels being received and converted
            this.depthPixels = new byte[this.depthFrameDescription.Width * this.depthFrameDescription.Height];

            // create the bitmap to display
            this.depthBitmap = new WriteableBitmap(this.depthFrameDescription.Width, this.depthFrameDescription.Height, 96.0, 96.0, PixelFormats.Gray8, null);

            // BODY CAPTURE
            
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
            //this.DataContext = skeletonImage;

            // Initialize the stringFrames to an empty set
            this.stringFrames = new List<string>();
            this.savedFrames = new List<string>();

            // initialize the components (controls) of the window
            this.InitializeComponent();


            showTraining();
        }

        private void Back_Click(object sender, RoutedEventArgs e)
        {
            MainWindow mainWin = new MainWindow();
            mainWin.Show();
            this.Close();
        }

        private void idButton_Click(object sender, RoutedEventArgs e)
        {
            Identification idWin = new Identification();
            idWin.Show();
            this.Close();
        }

        private void submitButton_Click(object sender, RoutedEventArgs e)
        {

            //submitRect.Visibility = Visibility.Visible;
            //submittingLabel.Visibility = Visibility.Visible;

            string outPath = @"C:\temp\POCM CODE\Skeletal Data\" + nameEntry.Text + "-skeleton.txt";

            // Delete temp file if it exists
            var i = 1;
            while (File.Exists(outPath))
            {
                if (i == 1)
                    outPath = outPath.Substring(0, outPath.Length - 4);
                else
                    outPath = outPath.Substring(0, outPath.Length - 6);
                Debug.Print(outPath);
                outPath += "-" + i;
                i += 1;
                outPath += ".txt";
            }
           
                

            this.GenerateSkeletalDataFile(outPath);

            //Make copy of skeletal data file so TASS can find it
            File.Copy(outPath, @"C:\temp\POCM CODE\Skeletal Data\skeleton.txt", true);

            string tassPath = @"C:\temp\POCM CODE\Generated Data\tass-skeleton.txt";



            // Delete temp file if it exists
            if (File.Exists(tassPath))
                File.Delete(tassPath);

            // Call TASS

            //matlab.Execute(@"Sample");
           
            // Retrieve processed TASS data
            string line;
            while (!File.Exists(tassPath));


            System.IO.StreamReader file = new System.IO.StreamReader(tassPath);
            
            line = file.ReadLine();
            tassFeatures = line.Split(',').Select(double.Parse).ToList();

            // Insert data into data store
            db.GetAllData();

            int id;
            if (db.GetRawData() == null)
                id = 0;
            else
                id = db.Count();

            string name = nameEntry.Text;
            db.Insert(id, name, tassFeatures);

            // Reopen sensor
            this.kinectSensor.Open();
            //submittingLabel.Visibility = Visibility.Hidden;
            //submitRect.Visibility = Visibility.Hidden;

        }

        private void discardButton_Click(object sender, RoutedEventArgs e)
        {
            //Reset nameEntry, reopen sensor, and delete saved video
            nameEntry.Text = "Enter Name of Subject";
            // Delete saved video (if we get there)
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
        private void Training_Loaded(object sender, RoutedEventArgs e)
        {
            if (this.bodyFrameReader != null)
            {
                this.bodyFrameReader.FrameArrived += this.Reader_FrameArrived;
            }

            nameEntry.Text = "Enter Name of Subject";
        }

        /// <summary>
        /// Execute shutdown tasks
        /// </summary>
        /// <param name="sender">object sending the event</param>
        /// <param name="e">event arguments</param>
        private void Training_Closing(object sender, CancelEventArgs e)
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

            idLabel.Visibility = Visibility.Hidden;
            nameLabel.Content = "";
            nameLabel.Visibility = Visibility.Hidden;
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
                    //dc.DrawRectangle(Brushes.Black, null, new Rect(552, 66, this.displayWidth, this.displayHeight));
                    dc.DrawRectangle(Brushes.Black, null, new Rect(0.0, 0.0, this.displayWidth, this.displayHeight));
                    //dc.DrawRectangle(Brushes.Black, null, new Rect(552, 66, 483, 422));

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

                            // For debugging purposes:
                            //Debug.Write(tmpFrame);
                        }
                    }

                    // prevent drawing outside of our render area
                    //this.drawingGroup.ClipGeometry = new RectangleGeometry(new Rect(552, 66, this.displayWidth, this.displayHeight));
                    this.drawingGroup.ClipGeometry = new RectangleGeometry(new Rect(0.0, 0.0, this.displayWidth, this.displayHeight));
                    //this.drawingGroup.ClipGeometry = new RectangleGeometry(new Rect(552, 66, 483, 422));
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
        //private void Sensor_IsAvailableChanged(object sender, IsAvailableChangedEventArgs e)
        //{
        //    // on failure, set the status text
        //    this.StatusText = this.kinectSensor.IsAvailable ? Properties.Resources.RunningStatusText
        //                                                    : Properties.Resources.SensorNotAvailableStatusText;
        //}

        /// <summary>
        /// Run the TASS (Temporal Alignment and Spectral Summary) with the generated input file
        /// </summary>
        public void GenerateSkeletalDataFile(String filename)
        {
            StreamWriter output = new StreamWriter(filename);
            int count = 1;
            int stringCount = 1;

            output.WriteLine("Microsoft Kinect SDK");                     // String of what we are using to extract the skeletal data
            output.WriteLine((savedFrames.Count - 2).ToString());         // Number of frames in the recording
            output.WriteLine(15.ToString());                              // Number of Joints which are processed

            //foreach (String s in savedFrames)
            for(int i=1;i<savedFrames.Count-1;i++)
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









        // Identification/Classifier code
        private void identifyButton_Click(object sender, RoutedEventArgs e)
        {
            idLabel.Visibility = Visibility.Visible;
            nameLabel.Visibility = Visibility.Visible;

            string outPath = @"C:\temp\POCM CODE\Skeletal Data\skeleton.txt";

            // Delete temp file if it exists
            if (File.Exists(outPath))
                File.Delete(outPath);

            this.GenerateSkeletalDataFile(outPath);

            string tassPath = @"C:\temp\POCM CODE\Generated Data\tass-skeleton.txt";



            // Delete temp file if it exists
            if (File.Exists(tassPath))
                File.Delete(tassPath);

            // Call TASS
            //matlab.Execute(@"Sample");

            // Retrieve processed TASS data
            string line;
            while (!File.Exists(tassPath)) ;

            
            System.IO.StreamReader file = new System.IO.StreamReader(tassPath);

            line = file.ReadLine();
            testData = line.Split(',').Select(double.Parse).ToList();

            // Create table containing test data
            DataTable testSubjectDataTable = new DataTable("TestFeatures");
            testSubjectDataTable.Columns.Add("Name", typeof(String));
            testSubjectDataTable.Columns.Add("LeftStepSize", typeof(double));
            testSubjectDataTable.Columns.Add("RightStepSize", typeof(double));
            testSubjectDataTable.Columns.Add("SteppingTime", typeof(double));
            testSubjectDataTable.Columns.Add("PosturalSwingLevel", typeof(double));
            testSubjectDataTable.Columns.Add("LeftHandSwingLevel", typeof(double));
            testSubjectDataTable.Columns.Add("RightHandSwingLevel", typeof(double));
            DataRow testRow = testSubjectDataTable.NewRow();
            testRow["Name"] = "TestSubject";
            testRow["LeftStepSize"] = testData[0];
            testRow["RightStepSize"] = testData[1];
            testRow["SteppingTime"] = testData[2];
            testRow["PosturalSwingLevel"] = testData[3];
            testRow["LeftHandSwingLevel"] = testData[4];
            testRow["RightHandSwingLevel"] = testData[5];
            testSubjectDataTable.Rows.Add(testRow);
           
            // Bind test data table to data grid 
            recordedDataGrid.ItemsSource = new DataView(testSubjectDataTable); // TODO: test that this works properly to convert list to dataTable


            //Send skeleton through classifier and return match from database
            Classifier();
        }


        private void ResetButton_OnClick(object sender, RoutedEventArgs e)
        {
            // Reopen sensor
            this.kinectSensor.Open();

            // Clear out identifying information
            nameLabel.Content = "";
            recordedDataGrid.ItemsSource = null;
            retrievedDataGrid.ItemsSource = null;

        }

        // Simple classifier which takes pre-processed data and compares it
        private void Classifier()
        {
            
            db.GetAllData();
            List<List<double>> dblList = db.GetFeatures();

            db.printLists();

            var diffList = new List<double> { };

            foreach (List<double> l in dblList)
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


            Console.WriteLine("MinIndex = " + minIndex);
            DataSet identifiedDataSet = db.GetRow(minIndex);
            String name = identifiedDataSet.Tables["Features"].Rows[0][0].ToString();
            retrievedDataGrid.ItemsSource = new DataView(identifiedDataSet.Tables["Features"]);  // TODO: Change query to get only name and 6 features
            nameLabel.Content = name;
            
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

        private void TrainingSelector_OnClick(object sender, RoutedEventArgs e)
        {
            showTraining();
        }

        private void IdentifySelector_OnClick(object sender, RoutedEventArgs e)
        {
            showIdentification();
        }

 
        // Allow ComboBox to save names
        public IEnumerable Items
        {
            get { return _items; }
        }

        public string SelectedItem
        {
            get { return _selectedItem; }
            set
            {
                _selectedItem = value;
                OnPropertyChanged("SelectedItem");
            }
        }

        public string NewItem
        {
            set
            {
                if (SelectedItem != null)
                {
                    return;
                }
                if (!string.IsNullOrEmpty(value) && !value.Equals("Enter Name of Subject"))
                {
                    _items.Add(value);
                    SelectedItem = value;
                }
            }
        }

        protected void OnPropertyChanged(string propertyName)
        {
            var handler = this.PropertyChanged;
            if (handler != null)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        public static DataTable ToDataTable<T>(List<T> items)
        {
            DataTable dataTable = new DataTable(typeof(T).Name);

            //Get all the properties
            PropertyInfo[] Props = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (PropertyInfo prop in Props)
            {
                //Setting column names as Property names
                dataTable.Columns.Add(prop.Name);
            }
            foreach (T item in items)
            {
                var values = new object[Props.Length];
                for (int i = 0; i < Props.Length; i++)
                {
                    //inserting property values to datatable rows
                    values[i] = Props[i].GetValue(item, null);
                }
                dataTable.Rows.Add(values);
            }
            //put a breakpoint here and check datatable
            return dataTable;
        }

        public void showTraining()
        {
            //Show Training UI elements
            nameEntry.Visibility = Visibility.Visible;
            submitButton.Visibility = Visibility.Visible;
            discardButton.Visibility = Visibility.Visible;

            //Hide Identification UI elements
            identifyButton.Visibility = Visibility.Hidden;
            resetButton.Visibility = Visibility.Hidden;
            idLabel.Visibility = Visibility.Hidden;
            nameLabel.Visibility = Visibility.Hidden;
            recordedDataGrid.Visibility = Visibility.Hidden;
            retrievedDataGrid.Visibility = Visibility.Hidden;
            MatchedDataLabel.Visibility = Visibility.Hidden;
            CapturedDataLabel.Visibility = Visibility.Hidden;
        }


        public void showIdentification()
        {
            //Hide Training UI elements
            nameEntry.Visibility = Visibility.Hidden;
            submitButton.Visibility = Visibility.Hidden;
            discardButton.Visibility = Visibility.Hidden;

            //Show Identification UI elements
            identifyButton.Visibility = Visibility.Visible;
            resetButton.Visibility = Visibility.Visible;
            recordedDataGrid.Visibility = Visibility.Visible;
            retrievedDataGrid.Visibility = Visibility.Visible;
            MatchedDataLabel.Visibility = Visibility.Visible;
            CapturedDataLabel.Visibility = Visibility.Visible;
            nameLabel.Content = "";
        }
    }
}