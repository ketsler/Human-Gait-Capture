using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    // Basically this is Sample.m
    class MatlabHandler
    {
        public MatlabHandler(String codeLocation)
        {
            object tmp;
            // Create the MATLAB instance 
            matlab = new MLApp.MLApp();

            // Change to the directory where the function is located 
            matlab.Execute("clear");
            matlab.Execute("cd '" + @codeLocation + "'");
            matlab.Feval("addPathTASS", 0, out tmp);
        }

        // Clear the matlab workspace
        public void clear()
        {
            matlab.Execute("clear");
        }

        // Change the matlab working location
        public void cd(String filename)
        {
            matlab.Execute("cd " + @filename);
        }

        public MLApp.MLApp getMatlab() { return matlab; }

        // Matlab instance
        private MLApp.MLApp matlab;

    }
}
