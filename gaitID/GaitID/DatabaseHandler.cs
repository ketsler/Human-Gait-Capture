using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;
using System.IO;
using System.Diagnostics;

namespace GaitID
{
    class DatabaseHandler
    {
        private MySqlConnection connection;
        private string server;
        private string database;
        private string uid;
        private string password;
        private string table;

        private List<List<double>> features;
        private List<List<object>> query_result;

        //Constructor
        public DatabaseHandler()
        {
            Initialize();
        }

        //Initialize values
        private void Initialize()
        {
            server = "localhost";
            database = "gait";
            uid = "root";
            password = "password";
            table = "features";
            string connectionString;
            connectionString = "SERVER=" + server + ";" + "DATABASE=" +
            database + ";" + "UID=" + uid + ";" + "PASSWORD=" + password + ";";
            query_result = new List<List<object>>();
            features = new List<List<double>>();
            connection = new MySqlConnection(connectionString);
        }

        //open connection to database
        private bool OpenConnection()
        {
            try
            {
                connection.Open();
                return true;
            }
            catch (MySqlException ex)
            {
                //When handling errors, you can your application's response based 
                //on the error number.
                //The two most common error numbers when connecting are as follows:
                //0: Cannot connect to server.
                //1045: Invalid user name and/or password.
                switch (ex.Number)
                {
                    case 0:
                        Console.WriteLine("Cannot connect to server.  Contact administrator");
                        break;

                    case 1045:
                        Console.WriteLine("Invalid username/password, please try again");
                        break;
                }
                return false;
            }
        }

        //Close connection
        private bool CloseConnection()
        {
            try
            {
                connection.Close();
                return true;
            }
            catch (MySqlException ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }

        }

        public List<List<double>> GetFeatures() { return features; }
        public List<List<object>> GetRawData() { return query_result;  }


        // Insert statement
        // The string you insert will be an SQL query string
        public void Insert(string query)
        {
            //open connection
            if (this.OpenConnection() == true)
            {
                //create command and assign the query and connection from the constructor
                MySqlCommand cmd = new MySqlCommand(query, connection);

                //Execute command
                cmd.ExecuteNonQuery();

                //close connection
                this.CloseConnection();
            }

        }

        //public void Insert(int id, string name, List<double> input_features)
        //{
        //    string query = "INSERT INTO " + table
        //        + " (ID,Name,LeftStepSize,RightStepSize,SteppingTime,PosturalSwingLevel,LeftHandSwingLevel,RightHandSwingLevel) "
        //        + " VALUES (" + id.ToString() + "," + "\"" + name + "\"" + ",";

        //    for (int i = 0; i < input_features.Count; i++) {
        //        if (i == input_features.Count - 1)
        //            query += (input_features[i].ToString() + ");");
        //        else
        //            query += (input_features[i].ToString() + ",");
        //    }

        //    Console.WriteLine(query);

        //    Insert(query);
        //}

        // Insert with name and with extra joint deviations
        public void Insert(int id, string name, List<double> input_features)
        {
            string query = "INSERT INTO " + table
                + " (ID, Name, LeftStepSize,RightStepSize,SteppingTime,PosturalSwingLevel,LeftHandSwingLevel,RightHandSwingLevel,JointDev1,JointDev2,JointDev3,JointDev4,JointDev5,JointDev6,JointDev7,JointDev8,JointDev9,JointDev10,JointDev11,JointDev12,JointDev13,JointDev14,JointDev15) "
                + " VALUES (" + id.ToString() + "," + "\"" + name + "\"" + ",";

            for (int i = 0; i < input_features.Count; i++)
            {
                if (i == input_features.Count - 1)
                    query += (input_features[i].ToString() + ");");
                else
                    query += (input_features[i].ToString() + ",");
            }

            Console.WriteLine(query);

            Insert(query);
        }

        //Update statement
        public void Update(string query)
        {
            //Open connection
            if (this.OpenConnection() == true)
            {
                //create mysql command
                MySqlCommand cmd = new MySqlCommand();
                //Assign the query using CommandText
                cmd.CommandText = query;
                //Assign the connection using Connection
                cmd.Connection = connection;

                //Execute query
                cmd.ExecuteNonQuery();

                //close connection
                this.CloseConnection();
            }
        }

        //Delete statement
        public void Delete(string query)
        {
            if (this.OpenConnection() == true)
            {
                MySqlCommand cmd = new MySqlCommand(query, connection);
                cmd.ExecuteNonQuery();
                this.CloseConnection();
            }
        }

        //Select statement
        public List<List<object>> GetAllData()
        {
            //  Left Step Size, Right Step Size, Stepping Time, Postural Swing Level, Left Hand Swing Level, Right Hand Swing Level.
            //Open connection
            if (this.OpenConnection() == true)
            {
                //Create Command
                string query = "SELECT * FROM features";
                MySqlCommand cmd = new MySqlCommand(query, connection);
                //Create a data reader and Execute the command
                MySqlDataReader dataReader = cmd.ExecuteReader();

                //Read the data and store them in the list
                while (dataReader.Read())
                {

                    List<object> list_object = new List<object>();
                    List<double> list_double = new List<double>();

                    // Add the id of the subject
                    list_object.Add(dataReader["ID"]);

                    // Add the name of the subject
                    list_object.Add(dataReader["Name"]);

                    // read the features
                    list_object.Add(dataReader["LeftStepSize"]);
                    list_object.Add(dataReader["RightStepSize"]);
                    list_object.Add(dataReader["SteppingTime"]);
                    list_object.Add(dataReader["PosturalSwingLevel"]);
                    list_object.Add(dataReader["LeftHandSwingLevel"]);
                    list_object.Add(dataReader["RightHandSwingLevel"]);
                    list_object.Add(dataReader["JointDev1"]);
                    list_object.Add(dataReader["JointDev2"]);
                    list_object.Add(dataReader["JointDev3"]);
                    list_object.Add(dataReader["JointDev4"]);
                    list_object.Add(dataReader["JointDev5"]);
                    list_object.Add(dataReader["JointDev6"]);
                    list_object.Add(dataReader["JointDev7"]);
                    list_object.Add(dataReader["JointDev8"]);
                    list_object.Add(dataReader["JointDev9"]);
                    list_object.Add(dataReader["JointDev10"]);
                    list_object.Add(dataReader["JointDev11"]);
                    list_object.Add(dataReader["JointDev12"]);
                    list_object.Add(dataReader["JointDev13"]);
                    list_object.Add(dataReader["JointDev14"]);
                    list_object.Add(dataReader["JointDev15"]);

                    // read the features
                    list_double.Add((double)dataReader["LeftStepSize"]);
                    list_double.Add((double)dataReader["RightStepSize"]);
                    list_double.Add((double)dataReader["SteppingTime"]);
                    list_double.Add((double)dataReader["PosturalSwingLevel"]);
                    list_double.Add((double)dataReader["LeftHandSwingLevel"]);
                    list_double.Add((double)dataReader["RightHandSwingLevel"]);
                    list_double.Add((double)dataReader["JointDev1"]);
                    list_double.Add((double)dataReader["JointDev2"]);
                    list_double.Add((double)dataReader["JointDev3"]);
                    list_double.Add((double)dataReader["JointDev4"]);
                    list_double.Add((double)dataReader["JointDev5"]);
                    list_double.Add((double)dataReader["JointDev6"]);
                    list_double.Add((double)dataReader["JointDev7"]);
                    list_double.Add((double)dataReader["JointDev8"]);
                    list_double.Add((double)dataReader["JointDev9"]);
                    list_double.Add((double)dataReader["JointDev10"]);
                    list_double.Add((double)dataReader["JointDev11"]);
                    list_double.Add((double)dataReader["JointDev12"]);
                    list_double.Add((double)dataReader["JointDev13"]);
                    list_double.Add((double)dataReader["JointDev14"]);
                    list_double.Add((double)dataReader["JointDev15"]);

                    query_result.Add(list_object);
                    features.Add(list_double);
                }

                //close Data Reader
                dataReader.Close();

                //close Connection
                this.CloseConnection();

                //return list to be displayed
                return query_result;
            }
            else
            {
                return query_result;
            }
        }

        public DataSet GetEverything()
        {
            string queryString = "SELECT * FROM features";
            MySqlDataAdapter adapter = new MySqlDataAdapter(queryString, connection);

            DataSet featuresDataSet = new DataSet();

            adapter.Fill(featuresDataSet, "Features");
            return featuresDataSet;
        }

        public DataSet GetRow(int idx)
        {
            string queryString = "SELECT Name,LeftStepSize,RightStepSize,SteppingTime,PosturalSwingLevel,LeftHandSwingLevel,RightHandSwingLevel," + 
                "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 FROM features WHERE ID = '" + idx + "'";
            MySqlDataAdapter adapter = new MySqlDataAdapter(queryString, connection);

            DataSet featuresDataSet = new DataSet();

            adapter.Fill(featuresDataSet, "Features");
            return featuresDataSet;
        }

        //Count statement
        public int Count()
        {
            string query = "SELECT Count(*) FROM " + table;
            int Count = -1;

            //Open Connection
            if (this.OpenConnection() == true)
            {
                //Create Mysql Command
                MySqlCommand cmd = new MySqlCommand(query, connection);

                //ExecuteScalar will return one value
                Count = int.Parse(cmd.ExecuteScalar() + "");

                //close Connection
                this.CloseConnection();

                return Count;
            }
            else
            {
                return Count;
            }
        }

        //Backup
        public void Backup()
        {
            try
            {
                DateTime Time = DateTime.Now;
                int year = Time.Year;
                int month = Time.Month;
                int day = Time.Day;
                int hour = Time.Hour;
                int minute = Time.Minute;
                int second = Time.Second;
                int millisecond = Time.Millisecond;

                //Save file to C:\ with the current date as a filename
                string path;
                path = "C:\\MySqlBackup" + year + "-" + month + "-" + day +
            "-" + hour + "-" + minute + "-" + second + "-" + millisecond + ".sql";
                StreamWriter file = new StreamWriter(path);


                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "mysqldump";
                psi.RedirectStandardInput = false;
                psi.RedirectStandardOutput = true;
                psi.Arguments = string.Format(@"-u{0} -p{1} -h{2} {3}",
                    uid, password, server, database);
                psi.UseShellExecute = false;

                Process process = Process.Start(psi);

                string output;
                output = process.StandardOutput.ReadToEnd();
                file.WriteLine(output);
                process.WaitForExit();
                file.Close();
                process.Close();
            }
            catch (IOException ex)
            {
                Console.WriteLine("Error , unable to backup!");
            }
        }

        //Restore
        public void Restore()
        {
            try
            {
                //Read file from C:\
                string path;
                path = "C:\\MySqlBackup.sql";
                StreamReader file = new StreamReader(path);
                string input = file.ReadToEnd();
                file.Close();

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "mysql";
                psi.RedirectStandardInput = true;
                psi.RedirectStandardOutput = false;
                psi.Arguments = string.Format(@"-u{0} -p{1} -h{2} {3}",
                    uid, password, server, database);
                psi.UseShellExecute = false;


                Process process = Process.Start(psi);
                process.StandardInput.WriteLine(input);
                process.StandardInput.Close();
                process.WaitForExit();
                process.Close();
            }
            catch (IOException ex)
            {
                Console.WriteLine("Error , unable to Restore!");
            }
        }

        public void printLists()
        {
            foreach (List<double> l in features)
            {
                foreach (double d in l)
                {
                    Console.Write(d.ToString() + ",");

                }
                Console.Write("\r\n");
            }

        }
    }
}
