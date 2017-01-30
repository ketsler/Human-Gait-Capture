using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    class SkeletonHandler
    {
        // Default constructor
        public SkeletonHandler()
        {
            frame = new List<Coordinate>();
            recording = new List<List<Coordinate>>();
            recording_tass = new List<List<Double>>();
        }

        // Add a Joint
        public bool addJoint(Double x, Double y, Double z) {
            var joint = new Coordinate(x, y, z);
            frame.Add(joint);
            return true;
        }

        // Add a frame - clears the frame variable after adding
        public bool addFrame()
        {
            recording.Add(frame);
            frame = new List<Coordinate>();
            return true;
        }

        // Load the legacy format of the skeleton files
        public bool loadFile(String filename)
        {
            int count = 1;
            int coordinateCount = 0;
            bool gotFrameNumber = false;
            bool lineSkipped = false;

            String[] lines = System.IO.File.ReadAllLines(filename);
            String[] splitString;

            foreach(String line in lines)
            {
                if (count < 4)
                {
                    // Do nothing
                } else if (gotFrameNumber == false)
                {
                    int frameNumber = Int32.Parse(line);
                    gotFrameNumber = true;
                }
                else if (gotFrameNumber == true && lineSkipped == false)
                {
                    lineSkipped = true;
                } else if (lineSkipped == true && coordinateCount < 15)
                {
                    splitString = line.Split(' ');
                    addJoint(Double.Parse(splitString[0]), Double.Parse(splitString[1]), Double.Parse(splitString[2]));
                    coordinateCount++;
                }

                if(coordinateCount == 15)
                {
                    coordinateCount = 0;
                    gotFrameNumber = false;
                    lineSkipped = false;
                    addFrame();
                }

                count++;
            }
            return true;
        }


        // Write the data to a text file
        public bool writeToFile()
        {
            String timeStamp = DateTime.Now.ToString("yyyyMMddHHmmssfff"); 
            Int64 counter = 1;
            StreamWriter file = new StreamWriter(".\\skeleton-dump-" + timeStamp + ".txt");
            foreach(var leFrame in recording) // leFrame --- tribute to Mousior Langou
            {
                file.WriteLine(counter.ToString());

                foreach(var coordinate in leFrame)
                {
                    file.WriteLine(coordinate.x.ToString() + " " + coordinate.y.ToString() + " " + coordinate.z.ToString());
                }
                file.WriteLine("");

                counter++;
            }

            return true;
        }

        // Convert the list to a format in which the TASS algorithms are accustomed
        // This results in a list which has All the X's, then the Y's and then the Z's
        // I.E X X X X X ... Y Y Y Y Y Y Y ... Z Z Z Z Z Z Z
        public bool formatToTASS()
        {
            foreach(var leFrame in recording)
            {
                var tmp_frame = new List<Double>();

                // X Values
                foreach(var leCoordinate in leFrame)
                {
                    tmp_frame.Add(leCoordinate.x);
                }
                // Y Values
                foreach(var leCoordinate in leFrame)
                {
                    tmp_frame.Add(leCoordinate.y);
                }
                // Z Values
                foreach(var leCoordinate in leFrame)
                {
                    tmp_frame.Add(leCoordinate.z);
                }

                recording_tass.Add(tmp_frame);
            }

            return true;
        }

        public bool printRecording()
        {
            foreach(List<Coordinate> leFrame in recording)
            {
                foreach(Coordinate coord in leFrame)
                {
                    Console.WriteLine(coord.x.ToString() + " " + coord.y.ToString() + " " + coord.z.ToString());
                }
                Console.WriteLine(" ");
            }

            return true;
        }

        public bool printRecordingTASS()
        {
            foreach(List<Double> leFrame in recording_tass)
            {
                foreach(Double number in leFrame)
                {
                    Console.WriteLine(number.ToString());
                }
            }

            return true;
        }

        public bool convertToArray()
        {
            int x = recording_tass.Count;
            int y = recording_tass[0].Count;
            recording_tass_array = new Double[x, y];

            for(int i = 0; i < x; i++)
            {
                for(int j = 0; j < y; j++)
                {
                    recording_tass_array[i, j] = recording_tass[i][j];
                }
            }

            return true;
        }
        
        public List<Coordinate> getFrame() { return frame; }
        public List<List<Coordinate>> getRecording() { return recording; }
        public List<List<Double>> getRecordingTASS() { return recording_tass; }
        public Double[,] getArray() { return recording_tass_array; }

        private List<Coordinate> frame;
        private List<List<Coordinate>> recording;    // This is essentially a list of the frames. Each of the frames is a List of coordinates.
        private List<List<Double>> recording_tass;   // This is how the TASS formats it (basically x x x x x x x x ... y y y y y y y y ... z z z z z z ...)
        private Double[,] recording_tass_array;      // This is the format that the matlab com library will accept
        
        // Used for pairing joints - originally located within LoadSkeleton
        public static int[,] List = { { 1, 2 }, { 2, 3 }, { 2, 4 }, { 4, 5 }, 
                               { 5, 6 }, { 2, 7 }, { 7, 8 }, { 8, 9 }, 
                               { 1, 10 }, { 10, 11 }, { 11, 12 },
                               { 1, 13 }, { 13, 14 }, { 14, 15 } };

    }
}
