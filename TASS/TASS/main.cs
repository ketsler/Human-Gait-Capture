using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TASS
{
    // Just to execute the TASS
    class main
    {
        static void Main(string[] args)
        {
            TASSDriver tass = new TASSDriver(@"C:\temp\POCM CODE");

            tass.Execute();

            // Prompt to prevent window from exiting
            Console.WriteLine("\r\nTASS execution complete. Press enter to exit...");
            Console.ReadLine();

        }
    }
}
